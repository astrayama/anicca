import Foundation

enum PlanTier: String, Codable, CaseIterable {
    case free = "free"
    case pro = "pro"
    case bundle = "bundle"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro ✦"
        case .bundle: return "Bundle ✦✦"
        }
    }

    var isPaid: Bool {
        self == .pro || self == .bundle
    }

    /// Maps the RevenueCat entitlements that are active right now to a tier. The identifiers
    /// match the entitlements in the RevenueCat dashboard; bundle includes everything in Pro.
    init(activeEntitlementIDs: Set<String>) {
        if activeEntitlementIDs.contains("bundle") {
            self = .bundle
        } else if activeEntitlementIDs.contains("pro") {
            self = .pro
        } else {
            self = .free
        }
    }

    // MARK: - What each tier allows (keep in step with `PlanFeature.all`)

    /// Free keeps the 7-day timeline; the 14-day and month views are Pro.
    static let freeTimelineDays = 7

    func allowsTimeline(days: Int) -> Bool {
        isPaid || days <= Self.freeTimelineDays
    }

    func hasReachedMonthlyLimit(checkInsThisMonth count: Int) -> Bool {
        !isPaid && count >= AppConfig.freeMonthlyCheckInLimit
    }

    /// Check-ins left this month, once a free user is close enough to the limit to be told.
    func checkInsLeftWarning(checkInsThisMonth count: Int) -> Int? {
        guard !isPaid,
              count >= AppConfig.freeMonthlyWarningThreshold,
              count < AppConfig.freeMonthlyCheckInLimit
        else { return nil }
        return AppConfig.freeMonthlyCheckInLimit - count
    }
}

/// One row of the paywall's Free vs Pro table. This list is what's behind the paywall: every
/// Pro-gated screen must appear here, and nothing may be listed that the app doesn't deliver.
struct PlanFeature: Identifiable, Equatable {
    let title: String
    let free: String
    let pro: String

    var id: String { title }

    static let included = "✓"
    static let notIncluded = "—"

    static let all: [PlanFeature] = [
        PlanFeature(title: "Check-ins per month", free: "\(AppConfig.freeMonthlyCheckInLimit)", pro: "Unlimited"),
        PlanFeature(title: "Chakra radar chart", free: included, pro: included),
        PlanFeature(title: "7-day timeline", free: included, pro: included),
        PlanFeature(title: "14-day + monthly timeline", free: notIncluded, pro: included),
        PlanFeature(title: "Weekly summary", free: notIncluded, pro: included),
        PlanFeature(title: "Weekly reflection", free: notIncluded, pro: included),
        PlanFeature(title: "Today's suggestion", free: notIncluded, pro: included),
        PlanFeature(title: "Check-in streak tracking", free: notIncluded, pro: included),
        PlanFeature(title: "Reminders", free: included, pro: included),
        PlanFeature(title: "PDF export", free: notIncluded, pro: included)
    ]
}
