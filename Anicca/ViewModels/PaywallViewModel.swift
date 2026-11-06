import Foundation
import RevenueCat

enum SubscriptionInterval: String {
    case monthly
    case annual
}

enum SelectedPlan: String {
    case pro
    case bundle
}

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var selectedInterval: SubscriptionInterval = .annual
    @Published var isWorking: Bool = false
    @Published var errorMessage: String?
    @Published var purchaseCompleted: Bool = false
    @Published var isLoadingOfferings: Bool = true

    @Published var packages: [Package] = []

    private let revenueCat = RevenueCatService.shared
    private let auth = AuthService.shared

    var proMonthlyPackage: Package? {
        packages.first { $0.storeProduct.productIdentifier == "anicca_pro_monthly" }
    }
    var proAnnualPackage: Package? {
        packages.first { $0.storeProduct.productIdentifier == "anicca_pro_annual" }
    }
    var bundleMonthlyPackage: Package? {
        packages.first { $0.storeProduct.productIdentifier == "anicca_bundle_monthly" }
    }
    var bundleAnnualPackage: Package? {
        packages.first { $0.storeProduct.productIdentifier == "anicca_bundle_annual" }
    }

    // Prices come only from loaded StoreKit products — never hardcoded fallbacks,
    // so the paywall can't show a price the store won't actually charge.
    var proPriceString: String? {
        formatPackage(selectedInterval == .monthly ? proMonthlyPackage : proAnnualPackage)
    }

    var bundlePriceString: String? {
        formatPackage(selectedInterval == .monthly ? bundleMonthlyPackage : bundleAnnualPackage)
    }

    var offeringsAvailable: Bool {
        proMonthlyPackage != nil || proAnnualPackage != nil
            || bundleMonthlyPackage != nil || bundleAnnualPackage != nil
    }

    private func formatPackage(_ pkg: Package?) -> String? {
        guard let pkg else { return nil }
        let price = pkg.storeProduct.localizedPriceString
        switch selectedInterval {
        case .monthly: return "\(price)/mo"
        case .annual:  return "\(price)/yr"
        }
    }

    /// App Review requires the paywall to state each subscription's title, length, and price.
    var subscriptionDisclosureLines: [String] {
        let entries: [(String, Package?)] = [
            ("Anicca Pro, 1 month", proMonthlyPackage),
            ("Anicca Pro, 1 year", proAnnualPackage),
            ("Pro + Yggdrasil Bundle, 1 month", bundleMonthlyPackage),
            ("Pro + Yggdrasil Bundle, 1 year", bundleAnnualPackage)
        ]
        return entries.compactMap { name, pkg in
            pkg.map { "\(name): \($0.storeProduct.localizedPriceString)" }
        }
    }

    // MARK: - Load

    func load() async {
        isLoadingOfferings = true
        defer { isLoadingOfferings = false }
        await revenueCat.fetchOfferings()
        if let current = revenueCat.currentOfferings?.current {
            self.packages = current.availablePackages
        } else {
            self.packages = []
        }
    }

    // MARK: - Purchase

    func buy(_ plan: SelectedPlan) async {
        let package: Package?
        switch (plan, selectedInterval) {
        case (.pro, .monthly): package = proMonthlyPackage
        case (.pro, .annual): package = proAnnualPackage
        case (.bundle, .monthly): package = bundleMonthlyPackage
        case (.bundle, .annual): package = bundleAnnualPackage
        }
        guard let package else {
            errorMessage = Strings.Paywall.purchaseFailed
            return
        }
        isWorking = true
        defer { isWorking = false }
        do {
            let tier = try await revenueCat.purchase(package: package)
            await auth.updatePlanTier(tier)
            purchaseCompleted = true
            NotificationCenter.default.post(name: .planUpgraded, object: nil)
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = Strings.Paywall.purchaseFailed
        }
    }

    func restore() async {
        isWorking = true
        defer { isWorking = false }
        do {
            let tier = try await revenueCat.restorePurchases()
            await auth.updatePlanTier(tier)
            purchaseCompleted = true
            NotificationCenter.default.post(name: .planUpgraded, object: nil)
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = Strings.Paywall.purchaseFailed
        }
    }
}
