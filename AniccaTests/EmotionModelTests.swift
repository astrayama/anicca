import XCTest

final class EmotionModelTests: XCTestCase {

    // MARK: - Ids

    func testIdIsCenterAndName() {
        let emotion = Emotion(name: "Anxious", center: .root, valence: .negative, definition: "x")
        XCTAssertEqual(emotion.id, "root::Anxious")
    }

    func testIdsAreUniqueAcrossTheLibrary() {
        let ids = EmotionLibrary.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testSameNameInDifferentCentersIsDifferent() {
        let a = Emotion(name: "Open", center: .heart, valence: .neutral, definition: "x")
        let b = Emotion(name: "Open", center: .crown, valence: .neutral, definition: "y")
        XCTAssertNotEqual(a, b)
        XCTAssertEqual(a, Emotion(name: "Open", center: .heart, valence: .neutral, definition: "changed"))
    }

    // MARK: - Zones

    func testEveryZoneHasWords() {
        for zone in EmotionZone.allCases {
            XCTAssertFalse(EmotionLibrary.byZone[zone, default: []].isEmpty, "\(zone) is empty")
        }
    }

    func testEveryWordAgreesWithItsZone() {
        for emotion in EmotionLibrary.all {
            XCTAssertTrue(emotion.zone.allowedValences.contains(emotion.valence),
                          "\(emotion.name) is \(emotion.valence) but sits in \(emotion.zone)")
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

    func testEveryV1WordResolvesToItsV1Valence() {
        for entry in V1LibraryFixture.entries {
            XCTAssertEqual(EmotionLibrary.valence(forStoredName: entry.name, center: entry.center), entry.valence,
                           "\(entry.name) lost its valence")
        }
    }

    func testStoredNamesAreCaseInsensitive() {
        XCTAssertEqual(EmotionLibrary.valence(forStoredName: "anxious", center: .root), .negative)
    }

    func testWordStoredUnderAnotherCenterStillResolves() {
        XCTAssertEqual(EmotionLibrary.valence(forStoredName: "Anxious", center: .crown), .negative)
    }

    func testUnknownNameHasNoValence() {
        XCTAssertNil(EmotionLibrary.valence(forStoredName: "Xyzzy", center: .root))
    }

    func testValenceTrendCountsStoredEntries() {
        let checkInId = UUID()
        let entries = [
            EmotionEntry(emotionName: "Anxious", energyCenter: .root, intensity: 3, checkInId: checkInId),
            EmotionEntry(emotionName: "Curious", energyCenter: .thirdEye, intensity: 3, checkInId: checkInId),
            EmotionEntry(emotionName: "Joyful", energyCenter: .sacral, intensity: 3, checkInId: checkInId),
            EmotionEntry(emotionName: "Disconnected", energyCenter: .root, intensity: 3, checkInId: checkInId),
            EmotionEntry(emotionName: "Xyzzy", energyCenter: .heart, intensity: 3, checkInId: checkInId),
        ]
        let trend = InsightsService().valenceTrend(in: entries)
        XCTAssertEqual(trend.positive, 1)
        XCTAssertEqual(trend.neutral, 1)
        XCTAssertEqual(trend.negative, 2)
    }
}
