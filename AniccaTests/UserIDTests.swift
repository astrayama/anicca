import XCTest
import SwiftData

/// Swift prints a UUID in UPPERCASE and Postgres prints it in lowercase. Local check-ins are
/// matched by a plain string compare, so a user must only ever have one spelling on the device.
@MainActor
final class UserIDTests: XCTestCase {

    private let sessionUUID = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private let postgresID = "e621e1f8-c36c-495a-93fc-0c247a3e6e5f"

    private var container: ModelContainer!
    private var store: LocalCheckInStore!

    override func setUp() async throws {
        let schema = Schema([CheckIn.self, EmotionEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        store = LocalCheckInStore(context: container.mainContext)
    }

    override func tearDown() async throws {
        store = nil
        container = nil
    }

    // MARK: - The helper

    func testNormalizedUUIDMatchesThePostgresSpelling() {
        XCTAssertEqual(UserID.normalized(sessionUUID), postgresID)
    }

    func testNormalizedLowercasesAnUppercaseString() {
        XCTAssertEqual(UserID.normalized(sessionUUID.uuidString), postgresID)
        XCTAssertEqual(UserID.normalized(postgresID), postgresID)
    }

    // MARK: - currentUser.id, whichever path built it

    func testFallbackProfileFromTheSessionUsesTheLowercaseID() {
        // `AuthService.loadProfile` builds this when the profile row can't be read.
        let fallback = UserProfile(id: sessionUUID.uuidString, email: "a@b.c")
        XCTAssertEqual(fallback.id, postgresID)
    }

    func testProfileFromTheRowAndTheFallbackShareOneID() {
        let fallback = UserProfile(id: sessionUUID.uuidString, email: "a@b.c")
        let loaded = UserProfile(row: profileRow(id: postgresID))
        XCTAssertEqual(fallback.id, loaded.id)
    }

    // MARK: - Local check-ins

    func testCheckInSavedWhileTheProfileFetchFailsShowsUpAfterTheProfileLoads() throws {
        let fallback = UserProfile(id: sessionUUID.uuidString, email: "a@b.c")
        insertCheckIn(userId: fallback.id)

        let loaded = UserProfile(row: profileRow(id: postgresID))
        XCTAssertEqual(store.checkIns(for: loaded.id).count, 1)
        XCTAssertEqual(store.monthCount(for: loaded.id), 1)
    }

    func testCheckInsAreFoundWhicheverSpellingTheCallerUses() throws {
        insertCheckIn(userId: postgresID)
        insertCheckIn(userId: sessionUUID.uuidString)

        XCTAssertEqual(store.checkIns(for: postgresID).count, 2)
        XCTAssertEqual(store.checkIns(for: sessionUUID.uuidString).count, 2)
    }

    func testNewCheckInsStoreTheLowercaseID() {
        let checkIn = CheckIn(userId: sessionUUID.uuidString)
        XCTAssertEqual(checkIn.userId, postgresID)
    }

    // MARK: - One-time repair of rows saved before the fix

    func testRepairLowercasesLegacyRowsAndIsSafeToRunAgain() throws {
        let legacy = insertCheckIn(userId: postgresID)
        legacy.userId = sessionUUID.uuidString // how a pre-fix row sits on disk
        insertCheckIn(userId: postgresID)
        try container.mainContext.save()

        XCTAssertEqual(try store.lowercaseUserIDs(), 1)
        XCTAssertEqual(legacy.userId, postgresID)
        XCTAssertEqual(store.monthCount(for: postgresID), 2)

        XCTAssertEqual(try store.lowercaseUserIDs(), 0)
        XCTAssertEqual(store.monthCount(for: postgresID), 2)
    }

    // MARK: - Helpers

    @discardableResult
    private func insertCheckIn(userId: String, createdAt: Date = Date()) -> CheckIn {
        let checkIn = CheckIn(userId: userId, createdAt: createdAt)
        container.mainContext.insert(checkIn)
        return checkIn
    }

    private func profileRow(id: String) -> UserProfileDTO {
        UserProfileDTO(
            id: id,
            email: "a@b.c",
            display_name: nil,
            plan_tier: "free",
            check_in_streak: 0,
            last_check_in_date: nil,
            total_check_ins: 0,
            reminder_enabled: false,
            reminder_time: nil,
            yggdrasil_user_id: nil,
            created_at: Date()
        )
    }
}
