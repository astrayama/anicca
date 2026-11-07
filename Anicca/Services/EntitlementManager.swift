import Foundation
import SwiftUI
import Combine

/// What the views gate on. Mirrors `RevenueCatService.planTier`, so a purchase, restore, renewal
/// or expiry reaches every screen as soon as RevenueCat reports it. What each tier includes is
/// listed in `PlanFeature.all` (the paywall table).
@MainActor
final class EntitlementManager: ObservableObject {
    static let shared = EntitlementManager()

    @Published private var _planTier: PlanTier = .free
    private var cancellable: AnyCancellable?

    private init(revenueCat: RevenueCatService = .shared) {
        _planTier = revenueCat.planTier
        cancellable = revenueCat.$planTier
            .removeDuplicates()
            .sink { [weak self] tier in self?._planTier = tier }
    }

    var planTier: PlanTier {
#if DEBUG
        if UserDefaults.standard.bool(forKey: "developer_override_pro") {
            return .pro
        }
#endif
        return _planTier
    }

    var isPro: Bool { planTier.isPaid }
    var isBundle: Bool { planTier == .bundle }
}
