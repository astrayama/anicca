import Foundation

/// Whether this install shares anonymous usage data, kept on this device only.
///
/// Sharing is on by default, but only once the person has seen the note about it on the sign-in
/// screen (decided Nov 8 2026). Until then nothing is sent. Switching it off in Settings is
/// remembered and wins from then on. It's deliberately not synced to the Supabase profile, which
/// would tie the setting, and this install's analytics ID, to the account.
enum UsageSharing {
    /// True once the sign-in screen's note has appeared on this install.
    static func noticeShown(in defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: AppConfig.usageNoticeShownKey)
    }

    static func recordNoticeShown(in defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: AppConfig.usageNoticeShownKey)
    }

    /// The Settings toggle, if the person has ever changed it.
    static func explicitChoice(in defaults: UserDefaults = .standard) -> Bool? {
        guard defaults.object(forKey: AppConfig.shareUsageDataKey) != nil else { return nil }
        return defaults.bool(forKey: AppConfig.shareUsageDataKey)
    }

    static func record(_ sharing: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(sharing, forKey: AppConfig.shareUsageDataKey)
    }

    /// The Settings choice if there is one, otherwise on once the note has been shown.
    static func isSharing(in defaults: UserDefaults = .standard) -> Bool {
        explicitChoice(in: defaults) ?? noticeShown(in: defaults)
    }
}
