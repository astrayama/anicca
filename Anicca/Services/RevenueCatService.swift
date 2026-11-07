import Foundation
import RevenueCat

/// The only place the app learns what a user has paid for. Every `CustomerInfo` RevenueCat
/// delivers (purchase, restore, renewal, expiry, refund, a grant from the dashboard, signing in
/// or out) goes through `apply(_:)`, which publishes `planTier`. `EntitlementManager` mirrors it
/// for the views, and the Supabase profile copy is synced from here too.
@MainActor
final class RevenueCatService: ObservableObject {
    static let shared = RevenueCatService()

    @Published var currentOfferings: Offerings?
    @Published private(set) var planTier: PlanTier = .free

    private var didConfigure = false
    private var customerInfoTask: Task<Void, Never>?

    private init() {}

    func configure(apiKey: String?) {
        guard !didConfigure else { return }
        guard let apiKey else {
            debugLog("⚠️ RevenueCat not configured: no usable API key for this build")
            return
        }
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: apiKey)
        didConfigure = true

        customerInfoTask = Task { [weak self] in
            for await info in Purchases.shared.customerInfoStream {
                await self?.apply(info)
            }
        }
    }

    // MARK: - Offerings

    func fetchOfferings() async {
        guard didConfigure else { return }
        do {
            let offerings = try await Purchases.shared.offerings()
            self.currentOfferings = offerings
        } catch {
            self.currentOfferings = nil
        }
    }

    // MARK: - Purchase

    func purchase(package: Package) async throws -> PlanTier {
        guard didConfigure else { throw AppError.purchaseFailed(Strings.Paywall.purchaseFailed) }
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled { throw AppError.purchaseCancelled }
            await apply(result.customerInfo)
            return planTier
        } catch let appError as AppError {
            throw appError
        } catch {
            throw RevenueCatErrorMapper.map(error)
        }
    }

    func restorePurchases() async throws -> PlanTier {
        guard didConfigure else { throw AppError.purchaseFailed(Strings.Paywall.purchaseFailed) }
        do {
            let info = try await Purchases.shared.restorePurchases()
            await apply(info)
            if planTier == .free { throw AppError.nothingToRestore }
            return planTier
        } catch let appError as AppError {
            throw appError
        } catch {
            throw RevenueCatErrorMapper.map(error)
        }
    }

    // MARK: - Entitlement check

    /// Refreshes the tier. If RevenueCat can't be reached the last known tier stays, so a paying
    /// user is never downgraded by a network error.
    @discardableResult
    func checkEntitlement() async -> PlanTier {
        guard didConfigure else { return planTier }
        if let info = try? await Purchases.shared.customerInfo() {
            await apply(info)
        }
        return planTier
    }

    private func apply(_ info: CustomerInfo) async {
        let tier = PlanTier(activeEntitlementIDs: Set(info.entitlements.active.keys))
        if tier != planTier { planTier = tier }
        await syncProfile(tier)
    }

    /// Keeps `profiles.plan_tier` in Supabase in step with RevenueCat. It's an informational copy:
    /// nothing gates on it. Only written for the signed-in user's own RevenueCat identity.
    private func syncProfile(_ tier: PlanTier) async {
        let auth = AuthService.shared
        guard let user = auth.currentUser,
              Purchases.shared.appUserID == RevenueCatKey.appUserID(forUserID: user.id),
              user.planTierRaw != tier.rawValue
        else { return }
        await auth.updatePlanTier(tier)
    }

    // MARK: - User identity

    func login(userId: String) async {
        guard didConfigure else { return }
        if let result = try? await Purchases.shared.logIn(RevenueCatKey.appUserID(forUserID: userId)) {
            await apply(result.customerInfo)
        }
    }

    func logout() async {
        guard didConfigure else { return }
        guard !Purchases.shared.isAnonymous else { return }
        if let info = try? await Purchases.shared.logOut() {
            await apply(info)
        }
    }
}
