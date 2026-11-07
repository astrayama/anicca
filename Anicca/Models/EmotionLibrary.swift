import Foundation

/// The emotion library: 70 plain words, 10 per energy center, each in one energy zone.
///
/// Source of truth for wording, zones and synonyms: `docs/emotion-library-v2.md` (approved
/// Nov 7, 2026). Check-ins store only `name` + `center`, so renaming or moving a shipped word
/// needs care: old names keep resolving through `EmotionLibrary.v1Valence`.
enum EmotionLibrary {
    static let all: [Emotion] = {
        let words = root + sacral + solar + heart + throat + thirdEye + crown
        assert(integrityProblems(in: words).isEmpty, "Emotion library breaks its rules: \(integrityProblems(in: words))")
        return words
    }()

    static let byCenter: [EnergyCenter: [Emotion]] = [
        .root: root,
        .sacral: sacral,
        .solar: solar,
        .heart: heart,
        .throat: throat,
        .thirdEye: thirdEye,
        .crown: crown
    ]

    static let byZone: [EmotionZone: [Emotion]] = Dictionary(grouping: all, by: \.zone)

    static func emotion(named name: String, in center: EnergyCenter) -> Emotion? {
        byCenter[center]?.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }

    /// A zone's words grouped by energy center, Root → Crown, skipping empty centers.
    /// Words keep library order inside each center.
    static func groups(in zone: EmotionZone) -> [(center: EnergyCenter, words: [Emotion])] {
        let words = byZone[zone] ?? []
        return EnergyCenter.allCases.compactMap { center in
            let inCenter = words.filter { $0.center == center }
            return inCenter.isEmpty ? nil : (center, inCenter)
        }
    }

    // MARK: - Root
    static let root: [Emotion] = [
        Emotion(name: "Anxious", center: .root, zone: .charged, valence: .negative,
                definition: "Worried about what might go wrong, tense and on edge.",
                synonyms: ["Worried", "Nervous", "Uneasy", "Tense", "Panicky", "Edgy"]),
        Emotion(name: "Scared", center: .root, zone: .charged, valence: .negative,
                definition: "Afraid of something that feels close and real right now.",
                synonyms: ["Afraid", "Frightened", "Fearful", "Terrified", "Spooked", "Unsafe"]),
        Emotion(name: "Restless", center: .root, zone: .charged, valence: .negative,
                definition: "Can't sit still or settle; your body wants to move.",
                synonyms: ["Fidgety", "Antsy", "Jittery", "Unsettled", "Wired", "Agitated"]),
        Emotion(name: "Energized", center: .root, zone: .bright, valence: .positive,
                definition: "Plenty of energy in your body and ready to go.",
                synonyms: ["Energetic", "Alive", "Hyper", "Full of energy", "Radiant"]),
        Emotion(name: "Okay", center: .root, zone: .steady, valence: .neutral,
                definition: "Not great, not bad, just getting through the day.",
                synonyms: ["Ok", "Fine", "Alright", "Not bad", "Neutral"]),
        Emotion(name: "Cautious", center: .root, zone: .steady, valence: .neutral,
                definition: "Taking it slow and watching closely before you trust or act.",
                synonyms: ["Hesitant", "Guarded", "Careful", "Wary", "Watchful", "On guard"]),
        Emotion(name: "Insecure", center: .root, zone: .steady, valence: .negative,
                definition: "Unsure of yourself or of where you stand with others.",
                synonyms: ["Self-conscious", "Shaky", "Awkward", "Unsure of myself"]),
        Emotion(name: "Safe", center: .root, zone: .calm, valence: .positive,
                definition: "Protected and looked after; nothing here can hurt you.",
                synonyms: ["Secure", "Supported", "Protected", "Sheltered", "Cozy"]),
        Emotion(name: "Grounded", center: .root, zone: .calm, valence: .positive,
                definition: "Steady in your body, feet on the floor, hard to knock over.",
                synonyms: ["Still", "Settled", "Stable", "Rooted", "Centered", "Balanced", "Anchored"]),
        Emotion(name: "Rested", center: .root, zone: .calm, valence: .positive,
                definition: "Your body has had the sleep or the break it needed.",
                synonyms: ["Refreshed", "Recharged", "Slept well", "Restored"])
    ]

    // MARK: - Sacral
    static let sacral: [Emotion] = [
        Emotion(name: "Jealous", center: .sacral, zone: .charged, valence: .negative,
                definition: "Wanting what someone else has, or scared of being replaced.",
                synonyms: ["Envious", "Envy", "Possessive", "FOMO"]),
        Emotion(name: "Happy", center: .sacral, zone: .bright, valence: .positive,
                definition: "Feeling good and light, with smiles that come easily.",
                synonyms: ["Joyful", "Blissful", "Glad", "Cheerful", "Good", "Delighted", "Upbeat"]),
        Emotion(name: "Excited", center: .sacral, zone: .bright, valence: .positive,
                definition: "Buzzing about something good that's coming or happening now.",
                synonyms: ["Passionate", "Thrilled", "Pumped", "Hyped", "Can't wait", "Stoked"]),
        Emotion(name: "Playful", center: .sacral, zone: .bright, valence: .positive,
                definition: "Silly and light, up for games, jokes and messing around.",
                synonyms: ["Silly", "Goofy", "Fun", "Cheeky", "Mischievous", "Giggly"]),
        Emotion(name: "Inspired", center: .sacral, zone: .bright, valence: .positive,
                definition: "Full of ideas and itching to make or try something new.",
                synonyms: ["Creative", "Flowing", "Imaginative", "Artistic", "In the flow"]),
        Emotion(name: "Emotional", center: .sacral, zone: .steady, valence: .neutral,
                definition: "Feelings sit close to the surface and spill over easily.",
                synonyms: ["Sensitive", "Teary", "Moody", "Nostalgic", "Stirred up", "Mood swings"]),
        Emotion(name: "Tired", center: .sacral, zone: .heavy, valence: .negative,
                definition: "Low on energy; your body and mind want rest.",
                synonyms: ["Sleepy", "Drowsy", "Wiped out", "Run down", "Lazy"]),
        Emotion(name: "Bored", center: .sacral, zone: .heavy, valence: .negative,
                definition: "Nothing grabs your interest and the time drags.",
                synonyms: ["Uninspired", "Unmotivated", "Meh", "Blah", "Uninterested"]),
        Emotion(name: "Numb", center: .sacral, zone: .heavy, valence: .negative,
                definition: "Feelings are switched off; nothing really gets through.",
                synonyms: ["Blank", "Flat", "Shut down", "Apathetic", "Unfeeling"]),
        Emotion(name: "Guilty", center: .sacral, zone: .heavy, valence: .negative,
                definition: "Bad about something you did and wishing you could undo it.",
                synonyms: ["Regretful", "Remorseful", "At fault", "To blame"])
    ]

    // MARK: - Solar Plexus
    static let solar: [Emotion] = [
        Emotion(name: "Angry", center: .solar, zone: .charged, valence: .negative,
                definition: "Hot and fired up at someone or something that crossed a line.",
                synonyms: ["Mad", "Furious", "Livid", "Fuming", "Raging"]),
        Emotion(name: "Frustrated", center: .solar, zone: .charged, valence: .negative,
                definition: "Blocked from what you want, and it keeps not working.",
                synonyms: ["Annoyed", "Irritated", "Irritable", "Fed up", "Aggravated", "Sick of it"]),
        Emotion(name: "Stressed", center: .solar, zone: .charged, valence: .negative,
                definition: "Under pressure, with too much riding on you and too little time.",
                synonyms: ["Stressed out", "Under pressure", "Pressured", "Frazzled"]),
        Emotion(name: "Overwhelmed", center: .solar, zone: .charged, valence: .negative,
                definition: "Too much at once; you can't keep up or take any more in.",
                synonyms: ["Swamped", "Drowning", "Burnt out", "Burned out", "Stretched thin", "Overloaded", "Snowed under"]),
        Emotion(name: "Confident", center: .solar, zone: .bright, valence: .positive,
                definition: "Sure of yourself and what you can do.",
                synonyms: ["Empowered", "Capable", "Bold", "Assured", "Self-assured", "Sure of myself"]),
        Emotion(name: "Proud", center: .solar, zone: .bright, valence: .positive,
                definition: "Pleased with something you did or someone you care about.",
                synonyms: ["Accomplished", "Pleased with myself", "Chuffed", "Successful"]),
        Emotion(name: "Motivated", center: .solar, zone: .bright, valence: .positive,
                definition: "Keen to get going and get things done.",
                synonyms: ["Ambitious", "Driven", "Eager", "Productive", "Keen"]),
        Emotion(name: "Determined", center: .solar, zone: .steady, valence: .neutral,
                definition: "Set on doing it, even when it's hard or slow.",
                synonyms: ["Persistent", "Stubborn", "Committed", "Won't give up"]),
        Emotion(name: "Helpless", center: .solar, zone: .heavy, valence: .negative,
                definition: "Unable to change what's happening, no matter what you try.",
                synonyms: ["Powerless", "Trapped", "Defeated", "Out of my depth"]),
        Emotion(name: "Ashamed", center: .solar, zone: .heavy, valence: .negative,
                definition: "Wanting to hide because you feel bad about who you are.",
                synonyms: ["Inadequate", "Embarrassed", "Humiliated", "Not good enough", "Worthless", "Useless"])
    ]

    // MARK: - Heart
    static let heart: [Emotion] = [
        Emotion(name: "Hurt", center: .heart, zone: .charged, valence: .negative,
                definition: "Stung by something someone said or did.",
                synonyms: ["Wounded", "Stung", "Betrayed", "Let down", "Offended"]),
        Emotion(name: "Resentful", center: .heart, zone: .charged, valence: .negative,
                definition: "Still angry about something unfair that was done to you.",
                synonyms: ["Bitter", "Resentment", "Grudge", "Not fair", "Hard done by"]),
        Emotion(name: "Loved", center: .heart, zone: .bright, valence: .positive,
                definition: "Wanted and cared about, just as you are.",
                synonyms: ["Accepted", "Cared for", "Adored", "Appreciated", "Included", "Valued"]),
        Emotion(name: "Vulnerable", center: .heart, zone: .steady, valence: .neutral,
                definition: "Exposed and unguarded, with your feelings out in the open.",
                synonyms: ["Exposed", "Raw", "Fragile", "Unguarded", "Defenseless"]),
        Emotion(name: "Sad", center: .heart, zone: .heavy, valence: .negative,
                definition: "Low and heavy-hearted; you might feel like crying.",
                synonyms: ["Unhappy", "Upset", "Down", "Blue", "Gloomy", "Miserable"]),
        Emotion(name: "Lonely", center: .heart, zone: .heavy, valence: .negative,
                definition: "Wanting company or closeness that isn't there right now.",
                synonyms: ["Yearning", "Alone", "Lonesome", "Isolated", "Left out", "Abandoned"]),
        Emotion(name: "Grieving", center: .heart, zone: .heavy, valence: .negative,
                definition: "Aching over someone or something you've lost.",
                synonyms: ["Grief", "Mourning", "Heartbroken", "Devastated", "Sorrow"]),
        Emotion(name: "Calm", center: .heart, zone: .calm, valence: .positive,
                definition: "Settled and unhurried; nothing is pulling at you.",
                synonyms: ["Peaceful", "Relaxed", "Chill", "At peace", "Serene", "Tranquil", "Mellow"]),
        Emotion(name: "Grateful", center: .heart, zone: .calm, valence: .positive,
                definition: "Thankful for something or someone good in your life.",
                synonyms: ["Thankful", "Appreciative", "Blessed", "Lucky"]),
        Emotion(name: "Caring", center: .heart, zone: .calm, valence: .positive,
                definition: "Warm toward someone and wanting good things for them.",
                synonyms: ["Tender", "Loving", "Compassionate", "Kind", "Affectionate", "Sympathetic", "Empathetic"])
    ]

    // MARK: - Throat
    static let throat: [Emotion] = [
        Emotion(name: "Misunderstood", center: .throat, zone: .charged, valence: .negative,
                definition: "People get you wrong, even when you try to explain.",
                synonyms: ["Misjudged", "Misread", "Judged", "Misinterpreted"]),
        Emotion(name: "Defensive", center: .throat, zone: .charged, valence: .negative,
                definition: "Feeling attacked and quick to push back or explain yourself.",
                synonyms: ["Attacked", "Prickly", "Touchy", "Argumentative"]),
        Emotion(name: "Expressive", center: .throat, zone: .bright, valence: .positive,
                definition: "Words and feelings come out of you easily.",
                synonyms: ["Articulate", "Talkative", "Chatty", "Vocal", "Outspoken"]),
        Emotion(name: "Brave", center: .throat, zone: .bright, valence: .positive,
                definition: "Scared maybe, but you speak up or step forward anyway.",
                synonyms: ["Courageous", "Daring", "Fearless", "Gutsy", "Spoke up"]),
        Emotion(name: "Honest", center: .throat, zone: .steady, valence: .neutral,
                definition: "Being real about what you think and feel, even when it's hard.",
                synonyms: ["Authentic", "Truthful", "Genuine", "Real", "Upfront", "Sincere"]),
        Emotion(name: "Quiet", center: .throat, zone: .steady, valence: .neutral,
                definition: "Not in the mood to talk; happy to listen and take things in.",
                synonyms: ["Listening", "Shy", "Reserved", "Introverted", "Silent"]),
        Emotion(name: "Withdrawn", center: .throat, zone: .heavy, valence: .negative,
                definition: "Pulling back from people and keeping to yourself.",
                synonyms: ["Closed", "Closed off", "Distant", "Antisocial", "Hiding", "Keeping to myself"]),
        Emotion(name: "Unheard", center: .throat, zone: .heavy, valence: .negative,
                definition: "No one is listening, or the words just won't come out.",
                synonyms: ["Silenced", "Constricted", "Ignored", "Muted", "Bottled up", "Talked over"]),
        Emotion(name: "Understood", center: .throat, zone: .calm, valence: .positive,
                definition: "Someone gets what you mean and how you feel.",
                synonyms: ["Heard", "Seen", "Listened to", "Validated", "Acknowledged"]),
        Emotion(name: "Relieved", center: .throat, zone: .calm, valence: .positive,
                definition: "Lighter now that something hard is over or finally said.",
                synonyms: ["Relief", "Off my chest", "Weight lifted", "Phew"])
    ]

    // MARK: - Third Eye
    static let thirdEye: [Emotion] = [
        Emotion(name: "Confused", center: .thirdEye, zone: .charged, valence: .negative,
                definition: "Can't make sense of what's going on or what to think.",
                synonyms: ["Puzzled", "Baffled", "Bewildered", "Mixed up", "Perplexed", "Disoriented"]),
        Emotion(name: "Distracted", center: .thirdEye, zone: .charged, valence: .negative,
                definition: "Your attention keeps jumping and won't stay on one thing.",
                synonyms: ["Scattered", "Unfocused", "Sidetracked", "Disorganized", "All over the place"]),
        Emotion(name: "Curious", center: .thirdEye, zone: .bright, valence: .positive,
                definition: "Wanting to find out more, explore and ask questions.",
                synonyms: ["Wondering", "Interested", "Intrigued", "Fascinated", "Inquisitive", "Open-minded"]),
        Emotion(name: "Focused", center: .thirdEye, zone: .bright, valence: .positive,
                definition: "Locked in on one thing while the rest fades out.",
                synonyms: ["Concentrating", "Locked in", "Absorbed", "Dialed in", "Attentive"]),
        Emotion(name: "Thoughtful", center: .thirdEye, zone: .steady, valence: .neutral,
                definition: "Turning something over in your mind, taking your time.",
                synonyms: ["Reflective", "Processing", "Contemplative", "Pensive", "Deep in thought", "Pondering"]),
        Emotion(name: "Torn", center: .thirdEye, zone: .steady, valence: .negative,
                definition: "Pulled two ways at once and unsure which to follow.",
                synonyms: ["Conflicted", "Indecisive", "Mixed feelings", "On the fence", "Ambivalent", "Divided"]),
        Emotion(name: "Foggy", center: .thirdEye, zone: .heavy, valence: .negative,
                definition: "Slow, cloudy thinking, like your head is full of cotton.",
                synonyms: ["Brain fog", "Hazy", "Muddled", "Fuzzy", "Cloudy", "Spaced out", "Zoned out"]),
        Emotion(name: "Doubtful", center: .thirdEye, zone: .heavy, valence: .negative,
                definition: "Not sure something is true, or that it will work out.",
                synonyms: ["Unsure", "Uncertain", "Skeptical", "Second-guessing", "Unconvinced"]),
        Emotion(name: "Clear-headed", center: .thirdEye, zone: .calm, valence: .positive,
                definition: "Thinking straight and seeing what matters.",
                synonyms: ["Clear-minded", "Clear", "Insightful", "Perceptive", "Lucid", "Level-headed", "Sharp"]),
        Emotion(name: "Mindful", center: .thirdEye, zone: .calm, valence: .positive,
                definition: "Fully here, noticing what's happening without rushing.",
                synonyms: ["Present", "Aware", "Observant", "Here and now"])
    ]

    // MARK: - Crown
    static let crown: [Emotion] = [
        Emotion(name: "Hopeful", center: .crown, zone: .bright, valence: .positive,
                definition: "Things could get better, and you're looking forward to it.",
                synonyms: ["Optimistic", "Encouraged", "Positive", "Looking forward"]),
        Emotion(name: "In awe", center: .crown, zone: .bright, valence: .positive,
                definition: "Amazed by something so big or beautiful it stops you.",
                synonyms: ["Transcendent", "Awe", "Amazed", "Awestruck", "Blown away", "Mind-blown"]),
        Emotion(name: "Lost", center: .crown, zone: .steady, valence: .negative,
                definition: "Unsure where you're headed or what you want from life.",
                synonyms: ["Directionless", "Aimless", "Adrift", "Off track"]),
        Emotion(name: "Searching", center: .crown, zone: .steady, valence: .neutral,
                definition: "Looking for answers, meaning, or where you fit.",
                synonyms: ["Seeking", "Questioning", "Exploring", "Figuring it out", "Soul-searching"]),
        Emotion(name: "Empty", center: .crown, zone: .heavy, valence: .negative,
                definition: "Hollow inside, like something important is missing.",
                synonyms: ["Meaningless", "Hollow", "Pointless", "Void", "Purposeless"]),
        Emotion(name: "Hopeless", center: .crown, zone: .heavy, valence: .negative,
                definition: "Sure things won't get better, so why even try.",
                synonyms: ["Cynical", "Despair", "Pessimistic", "Jaded", "Giving up", "No hope"]),
        Emotion(name: "Disconnected", center: .crown, zone: .heavy, valence: .negative,
                definition: "Cut off from people, from yourself, or from the world.",
                synonyms: ["Detached", "Cut off", "Dissociated", "Out of touch"]),
        Emotion(name: "Connected", center: .crown, zone: .calm, valence: .positive,
                definition: "Part of something bigger, and your life feels like it matters.",
                synonyms: ["Purposeful", "Unified", "Belonging", "In tune", "Part of something"]),
        Emotion(name: "Free", center: .crown, zone: .calm, valence: .positive,
                definition: "Nothing is holding you back; you can just be yourself.",
                synonyms: ["Open", "Liberated", "Carefree", "Letting go", "Unstuck"]),
        Emotion(name: "Content", center: .crown, zone: .calm, valence: .positive,
                definition: "Satisfied with things as they are; nothing feels missing.",
                synonyms: ["Whole", "Satisfied", "Fulfilled", "Complete"])
    ]

}
