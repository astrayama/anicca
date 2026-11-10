import Foundation

// Everything Anicca can send to PostHog, and the rules for what may leave the phone.
//
// Associated values are only small enums, Int and Bool. No case takes a String, so typed text,
// notes, emotion words, energy centers, intensities, names and account IDs can't be passed in,
// even by mistake. `AnalyticsPolicy` is a second check on the final payload, in
// `AnalyticsService`'s before-send hook. Kept free of the PostHog SDK so the unit tests compile it.

// MARK: - Property values

enum SignInMethod: String, Sendable {
    case apple
    case google
    case email
}

/// How the words in a check-in were picked. A check-in mixing sources reports `mixed`.
enum CheckInInputMethod: String, Sendable {
    case typed
    case browse
    case recent
    case mixed
}

enum MapMyFeelingsResult: String, Sendable {
    case added
    case alreadySelected = "already_selected"
    case noMatch = "no_match"
}

/// Where the paywall was opened from.
enum PaywallSource: String, Identifiable, Sendable {
    case logLimit = "log_limit"
    case settingsUpgrade = "settings_upgrade"
    case settingsPDF = "settings_pdf"
    case insightsRange = "insights_range"
    case insightsSummary = "insights_summary"
    case insightsReflection = "insights_reflection"
    case homeSuggestion = "home_suggestion"

    var id: String { rawValue }
}

enum PurchasePlan: String, Sendable {
    case pro
    case bundle
}

enum PurchaseInterval: String, Sendable {
    case monthly
    case annual
}

/// What a purchase tap was for. Never a price or a product ID.
struct PurchaseContext: Equatable, Sendable {
    let plan: PurchasePlan
    let interval: PurchaseInterval
    let source: PaywallSource
}

/// Why a purchase failed: a category, never the error message.
enum PurchaseFailure: String, Sendable {
    case network
    case store
    case plansUnavailable = "plans_unavailable"
    case other
}

enum RestoreResult: String, Sendable {
    case restored
    case nothingToRestore = "nothing_to_restore"
    case failed
}

enum ReflectionState: String, Sendable {
    case shown
    case empty
    case locked
}

enum ExportFormat: String, Sendable {
    case json
    case pdf
}

enum ReminderSource: String, Sendable {
    case onboarding
    case settings
}

/// A property value as it leaves the phone. `token` only ever holds an enum's raw value.
enum AnalyticsValue: Equatable, Sendable {
    case bool(Bool)
    case int(Int)
    case token(String)

    var json: Any {
        switch self {
        case .bool(let value): return value
        case .int(let value): return value
        case .token(let value): return value
        }
    }
}

// MARK: - Events

enum AnalyticsEvent: Equatable, Sendable {
    case onboardingCompleted(remindersEnabled: Bool, skippedIntro: Bool)
    case signedUp(method: SignInMethod, needsEmailConfirmation: Bool)
    case signedIn(method: SignInMethod)
    case checkInCreated(
        inputMethod: CheckInInputMethod,
        usedMapMyFeelings: Bool,
        emotionCount: Int,
        hasNote: Bool,
        checkInsThisMonth: Int,
        isFirstCheckIn: Bool
    )
    case mapMyFeelingsUsed(result: MapMyFeelingsResult, addedCount: Int)
    case freeLimitReached(limit: Int)
    case paywallViewed(source: PaywallSource, plansLoaded: Bool)
    case purchaseStarted(PurchaseContext)
    case purchaseCompleted(PurchaseContext)
    case purchaseCancelled(PurchaseContext)
    case purchaseFailed(PurchaseContext, reason: PurchaseFailure)
    case purchasesRestored(result: RestoreResult, source: PaywallSource)
    case weeklyReflectionViewed(state: ReflectionState)
    case exportCreated(format: ExportFormat, checkInCount: Int)
    case reminderEnabled(source: ReminderSource)
    case reminderDisabled
    case reminderPermissionDenied(source: ReminderSource)
    case signedOut
    case accountDeleted(method: SignInMethod)

    enum Name: String, CaseIterable, Sendable {
        case onboardingCompleted = "onboarding_completed"
        case signedUp = "signed_up"
        case signedIn = "signed_in"
        case checkInCreated = "checkin_created"
        case mapMyFeelingsUsed = "map_my_feelings_used"
        case freeLimitReached = "free_limit_reached"
        case paywallViewed = "paywall_viewed"
        case purchaseStarted = "purchase_started"
        case purchaseCompleted = "purchase_completed"
        case purchaseCancelled = "purchase_cancelled"
        case purchaseFailed = "purchase_failed"
        case purchasesRestored = "purchases_restored"
        case weeklyReflectionViewed = "weekly_reflection_viewed"
        case exportCreated = "export_created"
        case reminderEnabled = "reminder_enabled"
        case reminderDisabled = "reminder_disabled"
        case reminderPermissionDenied = "reminder_permission_denied"
        case signedOut = "signed_out"
        case accountDeleted = "account_deleted"
    }

    /// Every property key Anicca itself sets, including the `plan_tier` super property.
    enum Key: String, CaseIterable, Sendable {
        case planTier = "plan_tier"
        case remindersEnabled = "reminders_enabled"
        case skippedIntro = "skipped_intro"
        case method
        case needsEmailConfirmation = "needs_email_confirmation"
        case inputMethod = "input_method"
        case usedMapMyFeelings = "used_map_my_feelings"
        case emotionCount = "emotion_count"
        case hasNote = "has_note"
        case checkInsThisMonth = "checkins_this_month"
        case isFirstCheckIn = "is_first_checkin"
        case result
        case addedCount = "added_count"
        case limit
        case source
        case plansLoaded = "plans_loaded"
        case plan
        case interval
        case reason
        case state
        case format
        case checkInCount = "checkin_count"
    }

    var name: Name {
        switch self {
        case .onboardingCompleted: return .onboardingCompleted
        case .signedUp: return .signedUp
        case .signedIn: return .signedIn
        case .checkInCreated: return .checkInCreated
        case .mapMyFeelingsUsed: return .mapMyFeelingsUsed
        case .freeLimitReached: return .freeLimitReached
        case .paywallViewed: return .paywallViewed
        case .purchaseStarted: return .purchaseStarted
        case .purchaseCompleted: return .purchaseCompleted
        case .purchaseCancelled: return .purchaseCancelled
        case .purchaseFailed: return .purchaseFailed
        case .purchasesRestored: return .purchasesRestored
        case .weeklyReflectionViewed: return .weeklyReflectionViewed
        case .exportCreated: return .exportCreated
        case .reminderEnabled: return .reminderEnabled
        case .reminderDisabled: return .reminderDisabled
        case .reminderPermissionDenied: return .reminderPermissionDenied
        case .signedOut: return .signedOut
        case .accountDeleted: return .accountDeleted
        }
    }

    var properties: [Key: AnalyticsValue] {
        switch self {
        case let .onboardingCompleted(remindersEnabled, skippedIntro):
            return [.remindersEnabled: .bool(remindersEnabled), .skippedIntro: .bool(skippedIntro)]
        case let .signedUp(method, needsEmailConfirmation):
            return [.method: .token(method.rawValue), .needsEmailConfirmation: .bool(needsEmailConfirmation)]
        case let .signedIn(method):
            return [.method: .token(method.rawValue)]
        case let .checkInCreated(inputMethod, usedMapMyFeelings, emotionCount, hasNote, checkInsThisMonth, isFirstCheckIn):
            return [
                .inputMethod: .token(inputMethod.rawValue),
                .usedMapMyFeelings: .bool(usedMapMyFeelings),
                .emotionCount: .int(emotionCount),
                .hasNote: .bool(hasNote),
                .checkInsThisMonth: .int(checkInsThisMonth),
                .isFirstCheckIn: .bool(isFirstCheckIn)
            ]
        case let .mapMyFeelingsUsed(result, addedCount):
            return [.result: .token(result.rawValue), .addedCount: .int(addedCount)]
        case let .freeLimitReached(limit):
            return [.limit: .int(limit)]
        case let .paywallViewed(source, plansLoaded):
            return [.source: .token(source.rawValue), .plansLoaded: .bool(plansLoaded)]
        case let .purchaseStarted(context), let .purchaseCompleted(context), let .purchaseCancelled(context):
            return Self.properties(of: context)
        case let .purchaseFailed(context, reason):
            return Self.properties(of: context).merging([.reason: .token(reason.rawValue)]) { $1 }
        case let .purchasesRestored(result, source):
            return [.result: .token(result.rawValue), .source: .token(source.rawValue)]
        case let .weeklyReflectionViewed(state):
            return [.state: .token(state.rawValue)]
        case let .exportCreated(format, checkInCount):
            return [.format: .token(format.rawValue), .checkInCount: .int(checkInCount)]
        case let .reminderEnabled(source), let .reminderPermissionDenied(source):
            return [.source: .token(source.rawValue)]
        case .reminderDisabled, .signedOut:
            return [:]
        case let .accountDeleted(method):
            return [.method: .token(method.rawValue)]
        }
    }

    /// The properties in the shape the SDK takes.
    var payload: [String: Any] {
        Dictionary(uniqueKeysWithValues: properties.map { ($0.key.rawValue, $0.value.json) })
    }

    private static func properties(of context: PurchaseContext) -> [Key: AnalyticsValue] {
        [
            .plan: .token(context.plan.rawValue),
            .interval: .token(context.interval.rawValue),
            .source: .token(context.source.rawValue)
        ]
    }

    /// Supabase doesn't say whether an Apple or Google sign-in created the account, so an account
    /// created in the last minute counts as a sign-up.
    static func isNewAccount(createdAt: Date, now: Date = Date()) -> Bool {
        abs(now.timeIntervalSince(createdAt)) < 60
    }
}

// MARK: - What may leave the phone

/// The final check on every event, run in the SDK's before-send hook. Anything not listed here is
/// dropped: unknown events entirely, unknown properties one by one.
enum AnalyticsPolicy {
    /// The SDK's own lifecycle events. They carry only `from_background`, `version`, `build` and,
    /// after an update, `previous_version` / `previous_build`. Never a URL.
    static let lifecycleEvents: Set<String> = [
        "Application Installed",
        "Application Updated",
        "Application Opened",
        "Application Backgrounded"
    ]
    static let lifecycleKeys: Set<String> = ["from_background", "version", "build", "previous_version", "previous_build"]

    /// The SDK's default properties that are kept: app and OS version, device model, language,
    /// time zone and session bookkeeping. Nothing here is content or an identifier beyond the
    /// install's random ID. `$screen_name`, `$elements_chain`, URLs and referrers aren't listed, so
    /// they never pass.
    static let sdkKeys: Set<String> = [
        "distinct_id",
        "$app_name", "$app_version", "$app_build", "$app_namespace",
        "$is_testflight", "$is_sideloaded", "$is_emulator", "$is_ios_running_on_mac", "$is_mac_catalyst_app",
        "$device_manufacturer", "$device_model", "$device_type", "$device_name",
        "$os_name", "$os_version",
        "$lib", "$lib_version",
        "$screen_width", "$screen_height",
        "$locale", "$timezone",
        "$network_wifi", "$network_cellular",
        "$session_id", "$window_id",
        "$is_identified", "$process_person_profile", "$geoip_disable", "$groups"
    ]

    static let appEvents: Set<String> = Set(AnalyticsEvent.Name.allCases.map(\.rawValue))
    static let appKeys: Set<String> = Set(AnalyticsEvent.Key.allCases.map(\.rawValue))

    /// The event's properties with everything not allowed removed, or nil to drop the whole event.
    /// `dropped` lists the removed keys, for the Debug console.
    static func filter(event: String, properties: [String: Any]) -> (properties: [String: Any], dropped: [String])? {
        let allowed: Set<String>
        if appEvents.contains(event) {
            allowed = sdkKeys.union(appKeys)
        } else if lifecycleEvents.contains(event) {
            allowed = sdkKeys.union(lifecycleKeys).union([AnalyticsEvent.Key.planTier.rawValue])
        } else {
            return nil
        }
        var kept: [String: Any] = [:]
        var dropped: [String] = []
        for (key, value) in properties {
            if allowed.contains(key), isAllowedValue(value) {
                kept[key] = value
            } else {
                dropped.append(key)
            }
        }
        return (kept, dropped.sorted())
    }

    /// Only flat values pass: numbers, booleans, short strings, and `$groups` (always empty here).
    private static func isAllowedValue(_ value: Any) -> Bool {
        switch value {
        case is Bool, is Int, is Double, is NSNumber:
            return true
        case let string as String:
            return string.count <= 64
        case let dictionary as [String: Any]:
            return dictionary.isEmpty
        default:
            return false
        }
    }
}
