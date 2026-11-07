import XCTest

final class EmotionModelTests: XCTestCase {

    // MARK: - Library rules

    func testLibraryKeepsItsRules() {
        XCTAssertEqual(EmotionLibrary.integrityProblems(in: EmotionLibrary.all), [])
    }

    func testLibraryHasSeventyWords() {
        XCTAssertEqual(EmotionLibrary.all.count, 70)
    }

    func testIntegrityCheckCatchesBrokenRules() {
        var words = EmotionLibrary.all
        words[0] = Emotion(name: "Anxious", center: .root, zone: .calm, valence: .negative, definition: "x")
        let problems = EmotionLibrary.integrityProblems(in: words)
        XCTAssertTrue(problems.contains { $0.contains("Anxious is negative but sits in calm") }, "\(problems)")
    }

    // MARK: - Ids

    func testIdIsCenterAndName() {
        let emotion = Emotion(name: "Anxious", center: .root, zone: .charged, valence: .negative, definition: "x")
        XCTAssertEqual(emotion.id, "root::Anxious")
    }

    func testIdsAreUniqueAcrossTheLibrary() {
        let ids = EmotionLibrary.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testSameNameInDifferentCentersIsDifferent() {
        let a = Emotion(name: "Open", center: .heart, zone: .steady, valence: .neutral, definition: "x")
        let b = Emotion(name: "Open", center: .crown, zone: .steady, valence: .neutral, definition: "y")
        XCTAssertNotEqual(a, b)
        XCTAssertEqual(a, Emotion(name: "Open", center: .heart, zone: .steady, valence: .neutral, definition: "changed"))
    }

    // MARK: - Zones

    func testEveryZoneHasWords() {
        for zone in EmotionZone.allCases {
            XCTAssertFalse(EmotionLibrary.byZone[zone, default: []].isEmpty, "\(zone) is empty")
        }
    }

    func testGroupsFollowCenterOrderAndSkipEmptyCenters() {
        for zone in EmotionZone.allCases {
            let groups = EmotionLibrary.groups(in: zone)
            let order = groups.map { $0.center.number }
            XCTAssertEqual(order, order.sorted(), "\(zone) groups out of order")
            XCTAssertTrue(groups.allSatisfy { !$0.words.isEmpty })
            XCTAssertEqual(groups.flatMap(\.words).count, EmotionLibrary.byZone[zone, default: []].count)
        }
    }

    // MARK: - Old check-ins keep their valence

    /// Kept words whose valence changed in v2 on purpose (approved Nov 7, 2026). Old check-ins
    /// with these names follow the new valence.
    private let intentionalValenceChanges: Set<String> = ["Curious"]

    func testEveryV1WordStillResolves() {
        for entry in V1LibraryFixture.entries {
            let valence = EmotionLibrary.valence(forStoredName: entry.name, center: entry.center)
            XCTAssertNotNil(valence, "\(entry.name) lost its valence")
            if !intentionalValenceChanges.contains(entry.name) {
                XCTAssertEqual(valence, entry.valence, "\(entry.name) changed valence")
            }
        }
    }

    func testCuriousNowCountsAsPositive() {
        XCTAssertEqual(EmotionLibrary.valence(forStoredName: "Curious", center: .thirdEye), .positive)
    }

    func testRemovedV1WordsResolveThroughTheFrozenTable() {
        XCTAssertNil(EmotionLibrary.emotion(named: "Joyful", in: .sacral))
        XCTAssertEqual(EmotionLibrary.valence(forStoredName: "Joyful", center: .sacral), .positive)
        XCTAssertEqual(EmotionLibrary.valence(forStoredName: "Hollow", center: .crown), .negative)
        XCTAssertEqual(EmotionLibrary.valence(forStoredName: "Yielding", center: .sacral), .neutral)
    }

    func testOldRootDisconnectedResolvesToTheCrownWord() {
        XCTAssertNil(EmotionLibrary.emotion(named: "Disconnected", in: .root))
        XCTAssertEqual(EmotionLibrary.valence(forStoredName: "Disconnected", center: .root), .negative)
    }

    func testStoredNamesAreCaseInsensitive() {
        XCTAssertEqual(EmotionLibrary.valence(forStoredName: "anxious", center: .root), .negative)
    }

    func testUnknownNameHasNoValence() {
        XCTAssertNil(EmotionLibrary.valence(forStoredName: "Xyzzy", center: .root))
    }

    func testValenceTrendCountsOldAndNewEntries() {
        let checkInId = UUID()
        let entries = [
            EmotionEntry(emotionName: "Anxious", energyCenter: .root, intensity: 3, checkInId: checkInId),      // kept
            EmotionEntry(emotionName: "Okay", energyCenter: .root, intensity: 3, checkInId: checkInId),         // new, neutral
            EmotionEntry(emotionName: "Joyful", energyCenter: .sacral, intensity: 3, checkInId: checkInId),     // removed v1
            EmotionEntry(emotionName: "Hollow", energyCenter: .crown, intensity: 3, checkInId: checkInId),      // removed v1
            EmotionEntry(emotionName: "Disconnected", energyCenter: .root, intensity: 3, checkInId: checkInId), // old Root copy
            EmotionEntry(emotionName: "Xyzzy", energyCenter: .heart, intensity: 3, checkInId: checkInId),       // unknown
        ]
        let trend = InsightsService().valenceTrend(in: entries)
        XCTAssertEqual(trend.positive, 1)
        XCTAssertEqual(trend.neutral, 1)
        XCTAssertEqual(trend.negative, 3)
    }
}
