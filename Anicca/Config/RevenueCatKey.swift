import Foundation

/// Picks the RevenueCat API key for this build.
///
/// - Debug uses `REVENUECAT_TEST_API_KEY` (a Test Store `test_` key: fake purchases in the
///   simulator, no App Store Connect needed), falling back to `REVENUECAT_API_KEY`.
/// - Release uses `REVENUECAT_API_KEY` (the `appl_` key) and never a `test_` key: the SDK
///   deliberately crashes a Release build configured with a Test Store key. Without a usable key
///   the app skips RevenueCat and the paywall shows "Plans can't be loaded" instead.
enum RevenueCatKey {
    static func select(testKey: String, appleKey: String, isDebugBuild: Bool) -> String? {
        let test = usable(testKey)
        let apple = usable(appleKey)
        if isDebugBuild {
            return test ?? apple
        }
        guard let apple, !apple.hasPrefix("test_") else { return nil }
        return apple
    }

    /// The RevenueCat customer ID for a signed-in user. Supabase user IDs reach the app both as
    /// UPPERCASE (`UUID.uuidString`) and lowercase (Postgres rows); RevenueCat would treat those as
    /// two customers, and a purchase made as one would be invisible to the other.
    static func appUserID(forUserID userID: String) -> String {
        userID.lowercased()
    }

    /// Blank values and the template's `YOUR_…` placeholders aren't keys.
    private static func usable(_ raw: String) -> String? {
        let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, !key.hasPrefix("YOUR_") else { return nil }
        return key
    }
}
