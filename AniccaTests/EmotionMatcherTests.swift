import XCTest

/// Locks in how free text maps to library words. When the library changes, these expectations
/// change on purpose, so every behaviour change shows up in review.
final class EmotionMatcherTests: XCTestCase {

    private func names(_ text: String) -> [String] {
        EmotionMatcher.match(text).map(\.emotion.name)
    }

    private func intensity(of name: String, in text: String) -> Int? {
        EmotionMatcher.match(text).first { $0.emotion.name == name }?.intensity
    }

    // MARK: - Intensity words

    func testAmplifierRaisesIntensity() {
        XCTAssertEqual(intensity(of: "Anxious", in: "really anxious"), 4)
    }

    func testDoubleAmplifierIsStrongest() {
        XCTAssertEqual(intensity(of: "Tired", in: "so so tired"), 5)
    }

    func testSoftenerLowersIntensity() {
        XCTAssertEqual(intensity(of: "Numb", in: "kind of numb"), 2)
    }

    func testShoutingAndExclamationRaiseIntensity() {
        XCTAssertEqual(intensity(of: "Angry", in: "SO ANGRY!!"), 5)
    }

    func testPlainWordIsMiddleIntensity() {
        XCTAssertEqual(intensity(of: "Anxious", in: "anxious"), 3)
    }

    // MARK: - Negation and clauses

    func testNegationIsIgnored() {
        XCTAssertTrue(names("not happy").isEmpty)
    }

    func testNegationDoesNotCrossBut() {
        XCTAssertEqual(names("happy but tired"), ["Happy", "Tired"])
    }

    func testCantStopCryingIsNotNegated() {
        XCTAssertTrue(names("can't stop crying").contains("Sad"))
    }

    func testSentenceFromTheStartScreen() {
        let mapped = EmotionMatcher.match("I'm really anxious and kind of tired")
        XCTAssertEqual(mapped.map(\.emotion.name), ["Anxious", "Tired"])
        XCTAssertEqual(mapped.map(\.intensity), [4, 2])
    }

    // MARK: - Phrases and ambiguous words

    func testEverydayPhrase() {
        XCTAssertTrue(names("on edge").contains("Anxious"))
    }

    func testTiredOfMeansFedUp() {
        XCTAssertEqual(names("I'm tired of this"), ["Frustrated"])
    }

    func testAmbiguousWordNeedsAFeelingCue() {
        let mapped = names("I'm still tired")
        XCTAssertFalse(mapped.contains("Grounded"))
        XCTAssertTrue(mapped.contains("Tired"))
    }

    func testAmbiguousWordWithCueMatches() {
        XCTAssertTrue(names("I feel open").contains("Free"))
        XCTAssertEqual(names("I feel free"), ["Free"])
        XCTAssertEqual(names("I feel loved"), ["Loved"])
        XCTAssertEqual(names("I feel good"), ["Happy"])
    }

    func testEverydayUsesOfFeelingWordsDontCount() {
        XCTAssertTrue(names("I loved the movie").isEmpty)
        XCTAssertTrue(names("free time after school").isEmpty)
        XCTAssertTrue(names("good morning everyone").isEmpty)
        XCTAssertFalse(names("I got grounded yesterday").contains("Grounded"))
        XCTAssertFalse(names("I need to calm down").contains("Sad"))
    }

    func testShortAnswersMatchWithoutACue() {
        XCTAssertEqual(names("fine"), ["Okay"])
        XCTAssertEqual(names("okay"), ["Okay"])
    }

    func testNothingMatchesNonsense() {
        XCTAssertTrue(names("xyzzy").isEmpty)
    }

    func testAtMostFiveResults() {
        let text = "anxious, sad, angry, lonely, numb, confused, bored, guilty"
        XCTAssertLessThanOrEqual(EmotionMatcher.match(text).count, 5)
    }

    // MARK: - Search

    func testSearchPrefix() {
        XCTAssertEqual(EmotionMatcher.search("anx").first?.name, "Anxious")
    }

    func testSearchExactName() {
        XCTAssertEqual(EmotionMatcher.search("sad").first?.name, "Sad")
        XCTAssertEqual(EmotionMatcher.search("in awe").first?.name, "In awe")
        XCTAssertEqual(EmotionMatcher.search("clear-headed").first?.name, "Clear-headed")
    }

    func testSearchFindsRemovedV1NamesThroughSynonyms() {
        XCTAssertEqual(EmotionMatcher.search("joyful").first?.name, "Happy")
    }

    func testSearchEmptyQueryReturnsNothing() {
        XCTAssertTrue(EmotionMatcher.search("   ").isEmpty)
    }

    func testSearchFindsSynonyms() {
        XCTAssertTrue(EmotionMatcher.search("burnt out").map(\.name).contains("Overwhelmed"))
    }

    // MARK: - Tables stay in sync with the library

    func testEveryPhraseTargetIsALibraryWord() {
        let names = Set(EmotionLibrary.all.map(\.name))
        for (phrase, targets) in EmotionMatcher.everydayPhrases {
            for target in targets {
                XCTAssertTrue(names.contains(target), "\"\(phrase)\" points at unknown word \(target)")
            }
        }
    }

    func testCueAndIgnoreListsHaveNoDeadEntries() {
        func key(_ text: String) -> String {
            text.lowercased().replacingOccurrences(of: "-", with: " ")
        }
        let names = Set(EmotionLibrary.all.map { key($0.name) })
        let synonyms = Set(EmotionLibrary.all.flatMap(\.synonyms).map(key))
        let phrases = Set(EmotionMatcher.everydayPhrases.keys)
        for word in EmotionMatcher.needsCue {
            XCTAssertTrue(names.contains(word) || synonyms.contains(word) || phrases.contains(word),
                          "needsCue \"\(word)\" isn't a word, synonym or phrase")
        }
        for word in EmotionMatcher.freeTextIgnored {
            XCTAssertTrue(synonyms.contains(word), "freeTextIgnored \"\(word)\" isn't a synonym")
        }
    }
}
