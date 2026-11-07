import XCTest

/// Locks in what's behind the paywall. The paywall's Free vs Pro table is the source of truth for
/// v1 (Isa, Nov 7 2026); these tests fail if the table, the tier mapping or the limits drift apart.
final class PlanTests: XCTestCase {

    // MARK: - RevenueCat entitlements → tier

    func testNoActiveEntitlementIsFree() {
        XCTAssertEqual(PlanTier(activeEntitlementIDs: []), .free)
    }

    func testProEntitlementIsPro() {
        XCTAssertEqual(PlanTier(activeEntitlementIDs: ["pro"]), .pro)
    }

    func testBundleEntitlementIsBundle() {
        XCTAssertEqual(PlanTier(activeEntitlementIDs: ["bundle"]), .bundle)
    }

    func testBundleWinsOverPro() {
        XCTAssertEqual(PlanTier(activeEntitlementIDs: ["pro", "bundle"]), .bundle)
    }

    func testUnknownEntitlementIsFree() {
        XCTAssertEqual(PlanTier(activeEntitlementIDs: ["something_else"]), .free)
    }

    func testBundleUnlocksEverythingProDoes() {
        XCTAssertTrue(PlanTier.bundle.isPaid)
    }

    // MARK: - Timeline range

    func testFreeKeepsTheSevenDayTimeline() {
        XCTAssertTrue(PlanTier.free.allowsTimeline(days: 7))
    }

    func testFreeCannotOpenFourteenDayOrMonthTimeline() {
        XCTAssertFalse(PlanTier.free.allowsTimeline(days: 14))
        XCTAssertFalse(PlanTier.free.allowsTimeline(days: 30))
    }

    func testProOpensEveryTimelineRange() {
        for days in [7, 14, 30] {
            XCTAssertTrue(PlanTier.pro.allowsTimeline(days: days), "\(days) days")
            XCTAssertTrue(PlanTier.bundle.allowsTimeline(days: days), "\(days) days")
        }
    }

    // MARK: - Monthly check-in limit

    func testFreeIsStoppedAtTheMonthlyLimit() {
        XCTAssertFalse(PlanTier.free.hasReachedMonthlyLimit(checkInsThisMonth: 29))
        XCTAssertTrue(PlanTier.free.hasReachedMonthlyLimit(checkInsThisMonth: 30))
    }

    func testProHasNoMonthlyLimit() {
        XCTAssertFalse(PlanTier.pro.hasReachedMonthlyLimit(checkInsThisMonth: 500))
    }

    func testFreeIsWarnedFromTwentyFiveCheckIns() {
        XCTAssertNil(PlanTier.free.checkInsLeftWarning(checkInsThisMonth: 24))
        XCTAssertEqual(PlanTier.free.checkInsLeftWarning(checkInsThisMonth: 25), 5)
        XCTAssertEqual(PlanTier.free.checkInsLeftWarning(checkInsThisMonth: 29), 1)
        XCTAssertNil(PlanTier.free.checkInsLeftWarning(checkInsThisMonth: 30))
    }

    func testProIsNeverWarned() {
        XCTAssertNil(PlanTier.pro.checkInsLeftWarning(checkInsThisMonth: 27))
    }

    // MARK: - Paywall table

    private func row(_ title: String) -> PlanFeature? {
        PlanFeature.all.first { $0.title == title }
    }

    func testTableShowsTheLimitTheAppEnforces() {
        XCTAssertEqual(row("Check-ins per month")?.free, "\(AppConfig.freeMonthlyCheckInLimit)")
        XCTAssertEqual(row("Check-ins per month")?.pro, "Unlimited")
    }

    func testTableListsTodaysSuggestionAsPro() {
        XCTAssertEqual(row("Today's suggestion")?.free, PlanFeature.notIncluded)
        XCTAssertEqual(row("Today's suggestion")?.pro, PlanFeature.included)
    }

    func testTableListsLongerTimelineAsPro() {
        XCTAssertEqual(row("14-day + monthly timeline")?.free, PlanFeature.notIncluded)
    }

    func testTableKeepsRemindersFree() {
        XCTAssertEqual(row("Reminders")?.free, PlanFeature.included)
    }

    func testTableDoesNotAdvertiseTheUnbuiltYggdrasilIntegration() {
        XCTAssertFalse(PlanFeature.all.contains { $0.title.localizedCaseInsensitiveContains("yggdrasil") })
    }

    func testTableTitlesAreUnique() {
        let titles = PlanFeature.all.map(\.title)
        XCTAssertEqual(Set(titles).count, titles.count)
    }

    // MARK: - RevenueCat key per build

    func testDebugPrefersTheTestStoreKey() {
        XCTAssertEqual(RevenueCatKey.select(testKey: "test_abc", appleKey: "appl_xyz", isDebugBuild: true), "test_abc")
    }

    func testDebugFallsBackToTheMainKey() {
        XCTAssertEqual(RevenueCatKey.select(testKey: "", appleKey: "test_abc", isDebugBuild: true), "test_abc")
    }

    func testReleaseUsesTheAppleKey() {
        XCTAssertEqual(RevenueCatKey.select(testKey: "test_abc", appleKey: "appl_xyz", isDebugBuild: false), "appl_xyz")
    }

    /// The SDK crashes a Release build configured with a Test Store key, so it must never get one.
    func testReleaseRefusesATestStoreKey() {
        XCTAssertNil(RevenueCatKey.select(testKey: "", appleKey: "test_abc", isDebugBuild: false))
    }

    func testMissingKeysGiveNoKey() {
        XCTAssertNil(RevenueCatKey.select(testKey: "", appleKey: "  ", isDebugBuild: true))
        XCTAssertNil(RevenueCatKey.select(testKey: "", appleKey: "", isDebugBuild: false))
    }

    // MARK: - RevenueCat identity

    /// Supabase IDs arrive as UPPERCASE (`UUID.uuidString`) or lowercase (Postgres rows).
    /// RevenueCat treats those as two customers, so a purchase made as one vanishes as the other.
    func testRevenueCatCustomerIsTheSameWhateverTheIDCasing() {
        XCTAssertEqual(
            RevenueCatKey.appUserID(forUserID: "5A716FF2-8606-4EB2-A9EC-FF7AA1CA494E"),
            RevenueCatKey.appUserID(forUserID: "5a716ff2-8606-4eb2-a9ec-ff7aa1ca494e")
        )
    }

    func testRevenueCatCustomerIDIsLowercase() {
        XCTAssertEqual(RevenueCatKey.appUserID(forUserID: "ABC-123"), "abc-123")
    }

    func testTemplatePlaceholderIsNotAKey() {
        XCTAssertNil(RevenueCatKey.select(testKey: "", appleKey: "YOUR_REVENUECAT_PUBLIC_API_KEY", isDebugBuild: true))
    }
}
