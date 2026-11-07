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
        XCTAssertEqual(intensity(of: "Uninspired", in: "so so tired"), 5)
    }

    func testSoftenerLowersIntensity() {
        XCTAssertEqual(intensity(of: "Numb", in: "kind of numb"), 2)
    }

    func testShoutingAndExclamationRaiseIntensity() {
        XCTAssertEqual(intensity(of: "Frustrated", in: "SO ANGRY!!"), 5)
    }

    func testPlainWordIsMiddleIntensity() {
        XCTAssertEqual(intensity(of: "Anxious", in: "anxious"), 3)
    }

    // MARK: - Negation and clauses

    func testNegationIsIgnored() {
        XCTAssertTrue(names("not happy").isEmpty)
    }

    func testNegationDoesNotCrossBut() {
        XCTAssertEqual(names("happy but tired"), ["Joyful", "Uninspired"])
    }

    func testCantStopCryingIsNotNegated() {
        XCTAssertFalse(names("can't stop crying").isEmpty)
    }

    // MARK: - Phrases and ambiguous words

    func testEverydayPhrase() {
        XCTAssertTrue(names("on edge").contains("Anxious"))
    }

    func testAmbiguousWordNeedsAFeelingCue() {
        XCTAssertFalse(names("I'm still tired").contains("Still"))
    }

    func testAmbiguousWordWithCueMatches() {
        XCTAssertTrue(names("I feel open").contains("Open"))
    }

    func testNothingMatchesNonsense() {
        XCTAssertTrue(names("xyzzy").isEmpty)
    }

    func testAtMostFiveResults() {
        let text = "anxious, sad, angry, lonely, numb, confused, stuck, guilty"
        XCTAssertLessThanOrEqual(EmotionMatcher.match(text).count, 5)
    }

    // MARK: - Search

    func testSearchPrefix() {
        XCTAssertEqual(EmotionMatcher.search("anx").first?.name, "Anxious")
    }

    func testSearchEmptyQueryReturnsNothing() {
        XCTAssertTrue(EmotionMatcher.search("   ").isEmpty)
    }

    func testSearchFindsSynonyms() {
        XCTAssertTrue(EmotionMatcher.search("burnt out").map(\.name).contains("Overwhelmed"))
    }
}
