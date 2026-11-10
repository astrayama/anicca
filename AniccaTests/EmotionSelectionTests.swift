import XCTest

final class EmotionSelectionTests: XCTestCase {

    private let anxious = Emotion(name: "Anxious", center: .root, zone: .charged, valence: .negative, definition: "a")
    private let tired = Emotion(name: "Tired", center: .sacral, zone: .heavy, valence: .negative, definition: "b")
    private let calm = Emotion(name: "Calm", center: .heart, zone: .calm, valence: .positive, definition: "c")

    func testKeepsPickOrder() {
        var selection = EmotionSelection()
        selection.add(tired)
        selection.add(anxious)
        selection.add(calm)
        XCTAssertEqual(selection.items.map(\.emotion.name), ["Tired", "Anxious", "Calm"])
    }

    func testToggleAddsThenRemoves() {
        var selection = EmotionSelection()
        selection.toggle(anxious)
        XCTAssertTrue(selection.contains(anxious))
        XCTAssertEqual(selection.intensity(of: anxious), EmotionSelection.defaultIntensity)
        selection.toggle(anxious)
        XCTAssertTrue(selection.isEmpty)
    }

    func testAddNeverOverwritesTheUsersIntensity() {
        var selection = EmotionSelection()
        selection.add(anxious, intensity: 2)
        XCTAssertFalse(selection.add(anxious, intensity: 5))
        XCTAssertEqual(selection.intensity(of: anxious), 2)
        XCTAssertEqual(selection.count, 1)
    }

    func testIntensityIsClamped() {
        var selection = EmotionSelection()
        selection.add(anxious, intensity: 9)
        XCTAssertEqual(selection.intensity(of: anxious), 5)
        selection.setIntensity(0, for: anxious)
        XCTAssertEqual(selection.intensity(of: anxious), 1)
    }

    func testCountPerZone() {
        var selection = EmotionSelection()
        selection.add(anxious)
        selection.add(tired)
        XCTAssertEqual(selection.count(in: .charged), 1)
        XCTAssertEqual(selection.count(in: .heavy), 1)
        XCTAssertEqual(selection.count(in: .calm), 0)
    }

    func testEntriesMatchItems() {
        var selection = EmotionSelection()
        selection.add(calm, intensity: 4)
        XCTAssertEqual(selection.entries.first?.emotion, calm)
        XCTAssertEqual(selection.entries.first?.intensity, 4)
    }

    // MARK: - Where words came from (analytics only)

    func testOneSourceGivesThatInputMethod() {
        var selection = EmotionSelection()
        selection.add(anxious, source: .recent)
        selection.add(tired, source: .recent)
        XCTAssertEqual(selection.inputMethod, .recent)
        XCTAssertFalse(selection.usedMapMyFeelings)
    }

    func testTypedAndMappedWordsCountAsTyped() {
        var selection = EmotionSelection()
        selection.add(anxious, source: .typed)
        selection.add(tired, source: .mapped)
        XCTAssertEqual(selection.inputMethod, .typed)
        XCTAssertTrue(selection.usedMapMyFeelings)
    }

    func testDifferentSourcesAreMixed() {
        var selection = EmotionSelection()
        selection.add(anxious, source: .mapped)
        selection.toggle(calm, source: .browse)
        XCTAssertEqual(selection.inputMethod, .mixed)
    }

    func testRemovingAWordForgetsItsSource() {
        var selection = EmotionSelection()
        selection.add(anxious, source: .mapped)
        selection.add(calm, source: .browse)
        selection.remove(anxious)
        XCTAssertEqual(selection.inputMethod, .browse)
        XCTAssertFalse(selection.usedMapMyFeelings)
    }

    func testQueryModes() {
        XCTAssertEqual(LogQueryMode.mode(for: ""), .idle)
        XCTAssertEqual(LogQueryMode.mode(for: "   \n "), .idle)
        XCTAssertEqual(LogQueryMode.mode(for: "anx"), .words)
        XCTAssertEqual(LogQueryMode.mode(for: "burnt out"), .words)
        XCTAssertEqual(LogQueryMode.mode(for: "kind of numb"), .sentence)
    }
}
