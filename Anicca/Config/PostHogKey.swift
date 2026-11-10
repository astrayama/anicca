import Foundation

/// Picks the PostHog project key for this build.
///
/// - Debug uses `POSTHOG_DEBUG_API_KEY` (the "Anicca Debug" project) and never falls back to the
///   production key, so test events can't land in the real project.
/// - Release uses `POSTHOG_API_KEY` (the "Anicca" project).
///
/// Without a usable key the app runs with analytics switched off. `phc_` keys are public,
/// write-only ingest keys, but they still live in `Secrets.xcconfig`, out of git.
enum PostHogKey {
    static func select(debugKey: String, releaseKey: String, isDebugBuild: Bool) -> String? {
        usable(isDebugBuild ? debugKey : releaseKey)
    }

    /// Blank values and `YOUR_…` placeholders aren't keys.
    private static func usable(_ raw: String) -> String? {
        let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, !key.hasPrefix("YOUR_") else { return nil }
        return key
    }
}
