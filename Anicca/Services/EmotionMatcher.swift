import Foundation

// MARK: - Mapped Emotion

struct MappedEmotion: Identifiable {
    let id = UUID()
    let emotion: Emotion
    var intensity: Int          // 1–5, pre-filled from the user's wording (default 3)
    var isTouched: Bool = true  // Pre-filled means already "touched" → Save unlocks immediately
}

// MARK: - Emotion Matcher

/// Maps free text to emotions in `EmotionLibrary`, entirely on device.
///
/// Rule-based — no model, no network:
/// - A lexicon built from each emotion's name (strongest signal), its synonyms, and the
///   hand-written `everydayPhrases` table ("burnt out", "on edge", "can't focus").
/// - Negation: "not happy" / "never felt safe" are ignored.
/// - Intensity words: "really anxious" → 4, "so so tired" → 5, "kind of numb" → 2.
/// - Ambiguous everyday words ("still", "open", "fine") only count when the user is clearly
///   describing a feeling ("I feel open"), not in "I'm still tired".
enum EmotionMatcher {

    // MARK: - Public API

    /// Maps free text to at most `limit` emotions, returned in the order they appear in the text.
    static func match(_ text: String, limit: Int = 5) -> [MappedEmotion] {
        var hits: [String: Hit] = [:]
        var position = 0
        for clause in clauses(in: text) {
            scan(clause, offset: position, into: &hits)
            position += clause.tokens.count
        }
        return dropDuplicateNames(Array(hits.values))
            .sorted { a, b in
                if a.score != b.score { return a.score > b.score }
                if a.firstPosition != b.firstPosition { return a.firstPosition < b.firstPosition }
                return libraryIndex(a.emotion) < libraryIndex(b.emotion)
            }
            .prefix(limit)
            .sorted { a, b in
                a.firstPosition != b.firstPosition
                    ? a.firstPosition < b.firstPosition
                    : libraryIndex(a.emotion) < libraryIndex(b.emotion)
            }
            .map { MappedEmotion(emotion: $0.emotion, intensity: $0.intensity, isTouched: true) }
    }

    /// Ranks library emotions against a search query (Browse screen). Empty query → no results.
    static func search(_ query: String) -> [Emotion] {
        let q = normalizedKey(query)
        guard !q.isEmpty else { return [] }
        let queryStem = stem(q)
        let fromText = Set(match(query).map { $0.emotion.id })

        var scored: [(emotion: Emotion, score: Int)] = []
        for entry in searchIndex {
            let score: Int
            if entry.name == q {
                score = 100
            } else if entry.name.hasPrefix(q) {
                score = 80
            } else if entry.name.contains(q) {
                score = 60
            } else if entry.terms.contains(q) {
                score = 50
            } else if fromText.contains(entry.emotion.id) {
                score = 45
            } else if entry.terms.contains(where: { $0.hasPrefix(q) }) {
                score = 35
            } else if q.count >= 3, entry.terms.contains(where: { $0.contains(q) }) {
                score = 25
            } else if q.count >= 4,
                      stem(entry.name) == queryStem || entry.terms.contains(where: { stem($0) == queryStem }) {
                score = 20
            } else {
                continue
            }
            scored.append((entry.emotion, score))
        }
        return scored
            .sorted { $0.score != $1.score ? $0.score > $1.score : $0.emotion.name < $1.emotion.name }
            .map(\.emotion)
    }

    // MARK: - Everyday Phrases

    /// Hand-written phrases people actually type, mapped to emotion names in `EmotionLibrary`.
    /// Complements each emotion's `synonyms`; every target name must exist in the library.
    static let everydayPhrases: [String: [String]] = [
        // Worry & fear
        "anxiety": ["Anxious"],
        "panic": ["Anxious"],
        "panicking": ["Anxious"],
        "panicked": ["Anxious"],
        "panicky": ["Anxious"],
        "on edge": ["Anxious", "Restless"],
        "freaking out": ["Anxious"],
        "freaked out": ["Anxious"],
        "dread": ["Anxious"],
        "dreading": ["Anxious"],
        "fear": ["Anxious"],
        "terrified": ["Anxious"],
        "scary": ["Anxious"],
        "overthinking": ["Anxious", "Scattered"],
        "spiraling": ["Anxious", "Overwhelmed"],
        "spiralling": ["Anxious", "Overwhelmed"],
        "threatened": ["Insecure"],
        "not safe": ["Insecure"],
        "don't feel safe": ["Insecure"],
        "jittery": ["Restless"],
        "can't relax": ["Restless"],
        "can't sit still": ["Restless"],
        "can't sleep": ["Restless", "Anxious"],
        "impatient": ["Restless", "Frustrated"],

        // Overwhelm & exhaustion
        "stressed": ["Overwhelmed"],
        "stressed out": ["Overwhelmed", "Anxious"],
        "stress": ["Overwhelmed"],
        "stressful": ["Overwhelmed"],
        "burnt out": ["Overwhelmed"],
        "burned out": ["Overwhelmed"],
        "burnout": ["Overwhelmed"],
        "too much": ["Overwhelmed"],
        "exhausted": ["Overwhelmed"],
        "drained": ["Overwhelmed"],
        "worn out": ["Overwhelmed"],
        "stretched thin": ["Overwhelmed"],
        "under pressure": ["Overwhelmed"],
        "overstimulated": ["Overwhelmed", "Scattered"],
        "not okay": ["Overwhelmed"],
        "not ok": ["Overwhelmed"],
        "not alright": ["Overwhelmed"],
        "can't cope": ["Overwhelmed", "Powerless"],
        "can't handle": ["Overwhelmed", "Powerless"],
        "out of control": ["Powerless", "Overwhelmed"],

        // Low energy & flat
        "tired": ["Uninspired"],
        "meh": ["Uninspired"],
        "blah": ["Uninspired"],
        "lazy": ["Uninspired"],
        "sluggish": ["Uninspired", "Foggy"],
        "unproductive": ["Uninspired"],
        "no energy": ["Uninspired", "Overwhelmed"],
        "no motivation": ["Uninspired"],
        "feeling down": ["Hollow", "Uninspired"],
        "feel down": ["Hollow", "Uninspired"],
        "feeling low": ["Hollow", "Uninspired"],
        "feeling blue": ["Lonely"],
        "depressed": ["Hollow", "Uninspired"],
        "can't feel anything": ["Numb"],
        "feel nothing": ["Numb"],
        "don't care": ["Numb", "Uninspired"],
        "dead inside": ["Numb", "Hollow"],
        "empty inside": ["Hollow"],
        "not myself": ["Disconnected"],
        "nothing matters": ["Meaningless"],
        "what's the point": ["Meaningless"],
        "no purpose": ["Meaningless"],
        "hopeless": ["Powerless", "Meaningless"],

        // Sadness & hurt
        "sadness": ["Lonely", "Grieving"],
        "crying": ["Grieving", "Hurt"],
        "cried": ["Grieving", "Hurt"],
        "tears": ["Grieving", "Hurt"],
        "can't stop crying": ["Grieving", "Hurt"],
        "heartbreak": ["Grieving"],
        "loss": ["Grieving"],
        "hurting": ["Hurt"],
        "hurts": ["Hurt"],
        "broken": ["Hurt"],
        "pain": ["Hurt"],
        "bitter": ["Cynical", "Hurt"],
        "resentful": ["Hurt", "Frustrated"],
        "resentment": ["Hurt", "Frustrated"],
        "rejected": ["Lonely", "Hurt"],
        "unloved": ["Lonely", "Hurt"],
        "unwanted": ["Lonely", "Hurt"],
        "left out": ["Lonely", "Hurt"],
        "excluded": ["Lonely", "Hurt"],
        "no one cares": ["Lonely"],
        "nobody cares": ["Lonely"],
        "homesick": ["Yearning", "Lonely"],
        "nostalgic": ["Yearning"],
        "miss": ["Yearning"],
        "missing": ["Yearning"],

        // Anger
        "anger": ["Frustrated"],
        "rage": ["Frustrated"],
        "hate": ["Frustrated"],
        "pissed": ["Frustrated"],
        "pissed off": ["Frustrated"],
        "irritable": ["Frustrated"],
        "fed up": ["Frustrated"],

        // Self-worth
        "not good enough": ["Inadequate"],
        "useless": ["Inadequate"],
        "worthless": ["Inadequate"],
        "failure": ["Inadequate"],
        "imposter": ["Inadequate", "Doubtful"],
        "impostor": ["Inadequate", "Doubtful"],
        "self doubt": ["Doubtful", "Inadequate"],
        "hate myself": ["Inadequate", "Guilty"],
        "jealous": ["Inadequate", "Insecure"],
        "envious": ["Inadequate", "Insecure"],
        "guilt": ["Guilty"],
        "shame": ["Guilty"],
        "embarrassed": ["Guilty"],
        "regret": ["Guilty"],

        // Unheard & withdrawn
        "ignored": ["Silenced", "Misunderstood"],
        "unheard": ["Silenced", "Misunderstood"],
        "not heard": ["Silenced", "Misunderstood"],
        "not understood": ["Misunderstood"],
        "nobody listens": ["Silenced", "Misunderstood"],
        "no one listens": ["Silenced", "Misunderstood"],
        "judged": ["Misunderstood"],
        "criticized": ["Misunderstood", "Hurt"],
        "bottled up": ["Constricted"],
        "holding back": ["Constricted"],
        "choked up": ["Constricted"],
        "lump in my throat": ["Constricted"],
        "tight chest": ["Constricted", "Anxious"],
        "shy": ["Withdrawn"],
        "antisocial": ["Withdrawn"],
        "want to be alone": ["Withdrawn"],
        "disappear": ["Withdrawn", "Hollow"],
        "invisible": ["Withdrawn", "Hollow"],
        "hiding": ["Withdrawn"],

        // Mind
        "lost": ["Searching", "Confused"],
        "confusion": ["Confused"],
        "can't focus": ["Scattered", "Foggy"],
        "can't concentrate": ["Scattered", "Foggy"],
        "can't think": ["Foggy"],
        "brain fog": ["Foggy"],
        "indecisive": ["Hesitant", "Doubtful"],
        "fascinated": ["Curious"],
        "in the zone": ["Focused", "Flowing"],

        // Calm & okay
        "calm": ["Peaceful"],
        "relaxed": ["Peaceful"],
        "chill": ["Peaceful"],
        "content": ["Peaceful"],
        "at peace": ["Peaceful"],
        "peace": ["Peaceful"],
        "relieved": ["Peaceful"],
        "relief": ["Peaceful"],
        "okay": ["Stable"],
        "ok": ["Stable"],
        "alright": ["Stable"],
        "fine": ["Stable"],

        // Good energy
        "great": ["Joyful"],
        "amazing": ["Joyful"],
        "awesome": ["Joyful"],
        "wonderful": ["Joyful"],
        "fantastic": ["Joyful"],
        "excited": ["Passionate", "Joyful"],
        "thrilled": ["Joyful", "Passionate"],
        "silly": ["Playful"],
        "goofy": ["Playful"],
        "energized": ["Radiant"],
        "energetic": ["Radiant"],
        "alive": ["Radiant"],
        "hopeful": ["Open"],
        "optimistic": ["Open"],
        "proud": ["Confident"],
        "accomplished": ["Capable", "Confident"],
        "productive": ["Driven", "Capable"],
        "powerful": ["Empowered"],
        "in control": ["Empowered", "Assured"],
        "courage": ["Bold"],

        // Love & connection
        "love": ["Loving"],
        "in love": ["Loving", "Passionate"],
        "loved": ["Accepted", "Loving"],
        "appreciated": ["Accepted"],
        "gratitude": ["Grateful"],
        "compassion": ["Compassionate"],
        "empathy": ["Compassionate"],
        "forgive": ["Forgiving"],
        "feel seen": ["Understood", "Heard"],
        "spiritual": ["Transcendent", "Connected"],
        "awe": ["Transcendent"],
        "let go": ["Surrendering", "Yielding"],
        "letting go": ["Surrendering", "Yielding"],
        "purpose": ["Purposeful"],
    ]

    // MARK: - Word Lists

    /// Synonyms too generic to count as evidence in free text ("here", "real", "deep").
    /// They still work in Browse search.
    private static let freeTextIgnored: Set<String> = [
        "here", "real", "true", "original", "legitimate", "plain", "obvious", "evident", "transparent",
        "full", "entire", "total", "complete", "joined", "linked", "attached", "coupled", "united",
        "integrated", "amalgamated", "consolidated", "merged", "constant", "reliable", "firm", "solid",
        "established", "entrenched", "positive", "certain", "guaranteed", "effective", "direct", "frank",
        "digest", "absorb", "comprehend", "integrate", "analyze", "landing", "adjusting", "resting",
        "held", "backed", "able", "bright", "shining", "brilliant", "smooth", "continuous", "received",
        "accessible", "responsive", "welcoming", "informed", "sensible", "rational", "logical",
        "physical", "moving", "shifting", "looking", "hunting", "exploring", "hearing", "observing",
        "noting", "pausing", "lacking", "deep", "sharp", "soft", "mild", "delicate", "warm", "cold",
        "blue", "quiet", "tight", "restricted", "flat", "cloudy", "intense", "hungry", "pushed",
        "authorized", "enabled", "commanding", "interested", "understanding", "kind", "open", "naked",
        "obliged", "excusing", "allowing", "accepting", "flexible", "brewing", "innate", "untaught",
        "spontaneous", "divine", "vain", "seen", "unclosed", "unlocked", "unfastened", "ajar",
        "unsealed", "intent",
    ]

    /// Everyday words that only count when the user is describing a feeling
    /// ("I feel still", "so lost") or typed little else ("open, curious").
    private static let needsCue: Set<String> = [
        "still", "present", "open", "clear", "whole", "closed", "heard", "listening", "processing",
        "searching", "settling", "lost", "fine", "okay", "ok", "alright", "stable", "connected",
        "driven", "honest", "understood", "accepted", "supported", "safe", "bold", "broken", "content",
    ]

    private static let cueWords: Set<String> = [
        "feel", "feels", "feeling", "felt", "am", "being", "so", "very", "really", "pretty", "quite",
        "more", "less", "too", "kinda", "somewhat", "slightly", "totally", "completely", "deeply",
        "fully", "extremely", "incredibly", "super", "getting", "become", "becoming", "seem", "seems",
        "seemed", "kind", "sort", "little", "bit",
    ]

    private static let negators: Set<String> = ["not", "no", "never", "without", "nor", "neither"]
    /// "can't stop crying", "can't help feeling sad" — the negation targets the verb, not the feeling.
    private static let negationBreakers: Set<String> = ["stop", "help", "wait"]
    private static let conjunctions: Set<String> = ["and", "or", "because", "cause", "then", "yet", "although", "though", "while"]

    private static let amplifiers: Set<String> = [
        "really", "very", "so", "super", "extremely", "incredibly", "totally", "completely", "deeply",
        "utterly", "absolutely", "truly", "seriously", "terribly", "awfully", "too", "such",
    ]
    private static let maximizers: Set<String> = [
        "unbearably", "overwhelmingly", "insanely", "unbelievably", "ridiculously", "impossibly", "beyond",
    ]
    private static let softeners: Set<String> = ["slightly", "somewhat", "mildly", "kinda", "sorta", "little", "bit", "fairly", "partly"]
    private static let minimizers: Set<String> = ["barely", "hardly"]

    // MARK: - Scanning

    private struct Hit {
        let emotion: Emotion
        var score: Int
        var intensity: Int
        let firstPosition: Int
    }

    private static func scan(_ clause: Clause, offset: Int, into hits: inout [String: Hit]) {
        let tokens = clause.tokens
        var i = 0
        var lastMatchEnd = 0
        var negationWindow = 0  // tokens left in which a match counts as negated

        while i < tokens.count {
            if let found = phraseMatch(in: tokens, at: i, lastMatchEnd: lastMatchEnd) {
                let end = i + found.length
                if negationWindow == 0 {
                    let level = intensity(in: clause, match: i..<end, windowStart: max(lastMatchEnd, i - 3))
                    record(found.terms, intensity: level, position: offset + i, into: &hits)
                }
                negationWindow = 0
                lastMatchEnd = end
                i = end
                continue
            }

            let word = tokens[i].word
            if negators.contains(word) {
                negationWindow = 3
            } else if conjunctions.contains(word) {
                negationWindow = 0
            } else if negationWindow > 0 {
                let followsNegator = i > 0 && negators.contains(tokens[i - 1].word)
                negationWindow = (followsNegator && negationBreakers.contains(word)) ? 0 : negationWindow - 1
            }
            i += 1
        }
    }

    private struct PhraseMatch {
        let terms: [Term]
        let length: Int
    }

    /// Lexicon match at `i`, after applying the "needs a feeling cue" rule for ambiguous words.
    private static func phraseMatch(in tokens: [Token], at i: Int, lastMatchEnd: Int) -> PhraseMatch? {
        guard let found = lexiconLookup(tokens, at: i) else { return nil }
        if found.terms.contains(where: \.requiresCue) {
            // A list of feelings carries the cue along: "I feel still and open".
            let continuesList = i >= 1 && lastMatchEnd == i - 1 && ["and", "or"].contains(tokens[i - 1].word)
            let hasCue = tokens.count <= 2
                || continuesList
                || tokens[max(0, i - 2)..<i].contains { cueWords.contains($0.word) }
            // "still anxious", "clear minded": the ambiguous word is modifying the next feeling word.
            let modifiesNext = lexiconLookup(tokens, at: i + found.length) != nil
            if !hasCue || modifiesNext { return nil }
        }
        return found
    }

    /// Longest phrase first (so "burnt out" beats "out"), then a light-stem fallback for single words.
    private static func lexiconLookup(_ tokens: [Token], at i: Int) -> PhraseMatch? {
        guard i < tokens.count else { return nil }
        let maxLength = min(lexicon.maxPhraseLength, tokens.count - i)
        for length in stride(from: maxLength, through: 1, by: -1) {
            let key = tokens[i..<(i + length)].map(\.word).joined(separator: " ")
            if let terms = lexicon.phrases[key] {
                return PhraseMatch(terms: terms, length: length)
            }
        }
        let word = tokens[i].word
        let base = stem(word)
        if word.count >= 4, let terms = lexicon.stems[base] {
            return PhraseMatch(terms: terms, length: 1)
        }
        if base != word, base.count >= 5, let terms = lexicon.phrases[base] {
            return PhraseMatch(terms: terms, length: 1)
        }
        return nil
    }

    private static func intensity(in clause: Clause, match: Range<Int>, windowStart: Int) -> Int {
        let window = Array(clause.tokens[windowStart..<match.lowerBound])
        let words = window.map(\.word)
        let nearest = words.suffix(2)  // amplifiers must sit right before the feeling word
        let amplifierCount = nearest.filter { amplifiers.contains($0) }.count

        var level = 3
        if amplifierCount >= 2 || nearest.contains(where: { maximizers.contains($0) }) {
            level = 5
        } else if amplifierCount == 1 {
            level = 4
        } else if words.contains(where: { minimizers.contains($0) }) {
            level = 1
        } else if words.contains(where: { softeners.contains($0) }) || containsKindOf(words) {
            level = 2
        }
        if clause.exclaimed { level += 1 }
        if (window + clause.tokens[match]).contains(where: \.isShouted) { level += 1 }
        return min(5, max(1, level))
    }

    private static func containsKindOf(_ words: [String]) -> Bool {
        zip(words, words.dropFirst()).contains { ($0 == "kind" || $0 == "sort") && $1 == "of" }
    }

    private static func record(_ terms: [Term], intensity: Int, position: Int, into hits: inout [String: Hit]) {
        // An exact emotion name beats synonyms that happen to share the word ("hesitant").
        let named = terms.filter { $0.kind == .name }
        let chosen = named.isEmpty ? terms : named
        var seen = Set<String>()
        for term in chosen where seen.insert(term.emotion.id).inserted {
            if var hit = hits[term.emotion.id] {
                hit.score += term.weight
                hit.intensity = max(hit.intensity, intensity)
                hits[term.emotion.id] = hit
            } else {
                hits[term.emotion.id] = Hit(emotion: term.emotion, score: term.weight, intensity: intensity, firstPosition: position)
            }
        }
    }

    /// "Disconnected" and "Reflective" exist in two centers. Keep the copy whose center has the
    /// most other matches in this text; on a tie, the one listed first in the library.
    private static func dropDuplicateNames(_ hits: [Hit]) -> [Hit] {
        func support(_ hit: Hit) -> Int {
            hits.filter { $0.emotion.name != hit.emotion.name && $0.emotion.center == hit.emotion.center }.count
        }
        return Dictionary(grouping: hits, by: { $0.emotion.name }).values.compactMap { group in
            group.max { a, b in
                let (sa, sb) = (support(a), support(b))
                if sa != sb { return sa < sb }
                return libraryIndex(a.emotion) > libraryIndex(b.emotion)
            }
        }
    }

    private static let libraryOrder: [String: Int] = Dictionary(
        uniqueKeysWithValues: EmotionLibrary.all.enumerated().map { ($1.id, $0) }
    )

    private static func libraryIndex(_ emotion: Emotion) -> Int {
        libraryOrder[emotion.id] ?? Int.max
    }

    // MARK: - Tokenizing

    private struct Token {
        let word: String        // lowercased, accents folded, contractions expanded
        let isShouted: Bool     // typed in ALL CAPS (3+ letters)
    }

    private struct Clause {
        var tokens: [Token]
        var exclaimed: Bool
    }

    private static let clauseBreaks: Set<Character> = [".", ",", ";", ":", "!", "?", "\n", "\r", "(", ")", "—", "–", "…"]
    private static let apostrophes: Set<Character> = ["'", "’", "‘", "`", "ʼ"]

    /// Splits on punctuation and on the word "but", so "happy but tired" negation/intensity
    /// rules never leak across the split.
    private static func clauses(in text: String) -> [Clause] {
        var result: [Clause] = []
        var current = ""

        func flush(exclaimed: Bool) {
            let tokens = tokenize(current)
            current = ""
            guard !tokens.isEmpty else {
                // "sad!!" — extra marks belong to the clause before.
                if exclaimed, !result.isEmpty { result[result.count - 1].exclaimed = true }
                return
            }
            var parts: [[Token]] = [[]]
            for token in tokens {
                if token.word == "but" { parts.append([]) } else { parts[parts.count - 1].append(token) }
            }
            let nonEmpty = parts.filter { !$0.isEmpty }
            for (index, part) in nonEmpty.enumerated() {
                result.append(Clause(tokens: part, exclaimed: exclaimed && index == nonEmpty.count - 1))
            }
        }

        for character in text {
            if clauseBreaks.contains(character) {
                flush(exclaimed: character == "!")
            } else {
                current.append(character)
            }
        }
        flush(exclaimed: false)
        return result
    }

    private static func tokenize(_ text: String) -> [Token] {
        var tokens: [Token] = []
        var raw = ""

        func emit() {
            guard !raw.isEmpty else { return }
            let letters = raw.filter(\.isLetter)
            let shouted = letters.count >= 3 && letters == letters.uppercased() && letters != letters.lowercased()
            let folded = raw.lowercased().folding(options: .diacriticInsensitive, locale: nil)
            for word in expandContraction(folded) where !word.isEmpty {
                tokens.append(Token(word: word, isShouted: shouted))
            }
            raw = ""
        }

        for character in text {
            if character.isLetter {
                raw.append(character)
            } else if apostrophes.contains(character) {
                raw.append("'")
            } else {
                emit()  // spaces, hyphens, digits, punctuation all separate words
            }
        }
        emit()
        return tokens
    }

    private static let contractionForms: [String: [String]] = [
        "can't": ["can", "not"], "cannot": ["can", "not"], "cant": ["can", "not"],
        "won't": ["will", "not"], "shan't": ["shall", "not"], "ain't": ["is", "not"],
        "dont": ["do", "not"], "doesnt": ["does", "not"], "didnt": ["did", "not"],
        "isnt": ["is", "not"], "wasnt": ["was", "not"], "arent": ["are", "not"], "werent": ["were", "not"],
        "havent": ["have", "not"], "hasnt": ["has", "not"], "couldnt": ["could", "not"],
        "wouldnt": ["would", "not"], "shouldnt": ["should", "not"],
        "im": ["i", "am"],
    ]

    private static func expandContraction(_ raw: String) -> [String] {
        let word = raw.trimmingCharacters(in: CharacterSet(charactersIn: "'"))
        if let forms = contractionForms[word] { return forms }
        if word.hasSuffix("n't") { return [String(word.dropLast(3)), "not"] }
        if word.hasSuffix("'m") { return [String(word.dropLast(2)), "am"] }
        for suffix in ["'re", "'ve", "'ll", "'d", "'s"] where word.hasSuffix(suffix) {
            return [String(word.dropLast(suffix.count))]
        }
        return [word.replacingOccurrences(of: "'", with: "")]
    }

    private static func normalizedKey(_ text: String) -> String {
        tokenize(text).map(\.word).joined(separator: " ")
    }

    // MARK: - Stemming

    private static let stemRules: [(suffix: String, replacement: String)] = [
        ("iness", "y"), ("ily", "y"), ("ied", "y"), ("ies", "y"), ("sses", "ss"), ("ness", ""),
        ("ingly", ""), ("edly", ""), ("ing", ""), ("ed", ""), ("ly", ""), ("s", ""),
    ]

    /// Very light suffix stripping so "worrying" / "worries" / "worried" meet, and
    /// "frustrating" meets "frustrated". Words under 5 letters are left alone.
    static func stem(_ word: String) -> String {
        guard word.count >= 5 else { return word }
        for rule in stemRules where word.hasSuffix(rule.suffix) {
            if rule.suffix == "ly", word.hasSuffix("ely") { continue }                  // lonely, lovely
            if rule.suffix == "s", let before = word.dropLast().last, "sui".contains(before) { continue }  // anxious, hopeless
            let base = String(word.dropLast(rule.suffix.count)) + rule.replacement
            if base.count >= 3 { return base }
        }
        return word
    }

    // MARK: - Lexicon

    private enum TermKind { case name, synonym, phrase }

    private struct Term {
        let emotion: Emotion
        let kind: TermKind
        let requiresCue: Bool
        var weight: Int { kind == .name ? 3 : 2 }
    }

    private struct Lexicon {
        var phrases: [String: [Term]] = [:]
        var stems: [String: [Term]] = [:]
        var maxPhraseLength = 1

        mutating func add(_ text: String, emotion: Emotion, kind: TermKind) {
            let words = EmotionMatcher.tokenize(text).map(\.word)
            guard !words.isEmpty else { return }
            let key = words.joined(separator: " ")
            if kind != .name, EmotionMatcher.freeTextIgnored.contains(key) { return }
            if phrases[key]?.contains(where: { $0.emotion.id == emotion.id }) == true { return }

            let term = Term(emotion: emotion, kind: kind, requiresCue: EmotionMatcher.needsCue.contains(key))
            phrases[key, default: []].append(term)
            maxPhraseLength = max(maxPhraseLength, words.count)

            if words.count == 1 {
                let base = EmotionMatcher.stem(key)
                if base != key, stems[base]?.contains(where: { $0.emotion.id == emotion.id }) != true {
                    stems[base, default: []].append(term)
                }
            }
        }
    }

    private static let lexicon: Lexicon = {
        var lexicon = Lexicon()
        for emotion in EmotionLibrary.all {
            lexicon.add(emotion.name, emotion: emotion, kind: .name)
        }
        for emotion in EmotionLibrary.all {
            for synonym in emotion.synonyms {
                lexicon.add(synonym, emotion: emotion, kind: .synonym)
            }
        }
        for (phrase, names) in everydayPhrases {
            for name in names {
                let targets = EmotionLibrary.all.filter { $0.name == name }
                assert(!targets.isEmpty, "everydayPhrases: \"\(phrase)\" points at unknown emotion \"\(name)\"")
                for target in targets {
                    lexicon.add(phrase, emotion: target, kind: .phrase)
                }
            }
        }
        return lexicon
    }()

    // MARK: - Search Index

    private struct SearchEntry {
        let emotion: Emotion
        let name: String
        let terms: [String]
    }

    private static let searchIndex: [SearchEntry] = {
        var phrasesByName: [String: [String]] = [:]
        for (phrase, names) in everydayPhrases {
            for name in names {
                phrasesByName[name, default: []].append(normalizedKey(phrase))
            }
        }
        return EmotionLibrary.all.map { emotion in
            SearchEntry(
                emotion: emotion,
                name: normalizedKey(emotion.name),
                terms: emotion.synonyms.map(normalizedKey) + (phrasesByName[emotion.name] ?? [])
            )
        }
    }()
}
