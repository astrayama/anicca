import XCTest
import SwiftData

/// The Insights tab's Mood Timeline: one dot per day, coloured by that day's dominant center.
@MainActor
final class InsightsServiceTests: XCTestCase {

    private var container: ModelContainer!
    private let insights = InsightsService()
    private let calendar = Calendar.current
    /// Mid-afternoon, so "days ago" never lands on the other side of midnight.
    private lazy var now: Date = calendar.date(from: DateComponents(year: 2026, month: 11, day: 7, hour: 15))!

    override func setUp() async throws {
        let schema = Schema([CheckIn.self, EmotionEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
    }

    override func tearDown() async throws {
        container = nil
    }

    // MARK: - Helpers

    private func day(_ daysAgo: Int) -> Date {
        calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: now))!
    }

    private func checkIn(daysAgo: Int, hour: Int = 10, _ words: [(String, EnergyCenter, Int)]) -> CheckIn {
        let createdAt = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day(daysAgo))!
        let checkIn = CheckIn(userId: "user", createdAt: createdAt)
        container.mainContext.insert(checkIn)
        for (name, center, intensity) in words {
            let entry = EmotionEntry(emotionName: name, energyCenter: center, intensity: intensity,
                                     checkInId: checkIn.id, checkIn: checkIn)
            checkIn.entries.append(entry)
            container.mainContext.insert(entry)
        }
        return checkIn
    }

    // MARK: - Mood Timeline

    func testEveryDayInTheRangeIsThereEvenWithoutCheckIns() {
        let timeline = insights.moodTimeline(for: 7, from: [], now: now)

        XCTAssertEqual(timeline.count, 7)
        XCTAssertEqual(Set(timeline.keys), Set((0..<7).map(day)))
        XCTAssertTrue(timeline.values.allSatisfy { $0 == nil })
    }

    func testEachDayShowsItsDominantCenter() {
        let checkIns = [
            checkIn(daysAgo: 0, [("Grateful", .heart, 4)]),
            checkIn(daysAgo: 2, hour: 9, [("Anxious", .root, 3)]),
            checkIn(daysAgo: 2, hour: 20, [("Content", .crown, 5)]), // same day: Crown outweighs Root
            checkIn(daysAgo: 10, [("Proud", .solar, 5)])              // outside the week
        ]

        let timeline = insights.moodTimeline(for: 7, from: checkIns, now: now)

        XCTAssertEqual(timeline.count, 7)
        XCTAssertEqual(timeline[day(0)], .some(.heart))
        XCTAssertEqual(timeline[day(1)], .some(nil), "a day without check-ins keeps its slot, with no center")
        XCTAssertEqual(timeline[day(2)], .some(.crown))
        XCTAssertNil(timeline[day(10)], "days outside the range are left out")
    }

    func testRangeLengthFollowsTheRequestedDays() {
        XCTAssertEqual(insights.moodTimeline(for: 14, from: [], now: now).count, 14)
        XCTAssertEqual(insights.moodTimeline(for: 30, from: [], now: now).count, 30)
    }
}
