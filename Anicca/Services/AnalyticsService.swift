import Foundation
import Combine
import PostHog

/// Anonymous usage analytics (PostHog, EU cloud). The only file that imports the PostHog SDK.
///
/// - Anonymous: `identify` is never called and no person profiles are made. Each install has a
///   random ID, which is replaced on sign-out, account deletion and opt-out.
/// - On by default, but nothing is sent until the sign-in screen's note about it has appeared, and
///   never once the person switches "Share anonymous usage data" off in Settings (`UsageSharing`).
/// - Every capture feature that could pick up what someone wrote is off (autocapture, screen views,
///   session replay, surveys, rage clicks), and `AnalyticsPolicy` filters every payload.
/// - Without a PostHog key for this build (`AppConfig.posthogAPIKey`), every call is a no-op.
@MainActor
final class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()

    @Published private(set) var isSharing: Bool

    private var isConfigured = false
    private var planTier: PlanTier = .free
    private var planTierChange: AnyCancellable?

    private init() {
        isSharing = UsageSharing.isSharing()
    }

    // MARK: - Setup

    func configure(apiKey: String?, host: String) {
        guard !isConfigured else { return }
        guard let apiKey else {
            debugLog("⚠️ Analytics off: no PostHog key for this build")
            return
        }
        let sharing = isSharing
        let config = PostHogConfig(projectToken: apiKey, host: host)

        // App opens, installs and updates only, for active users and retention. No URL.
        config.captureApplicationLifecycleEvents = true
        // Off: SwiftUI screen names are meaningless, and the last one rides on every event.
        config.captureScreenViews = false
        // Off: UIKit autocapture records text field and text view contents (a check-in note).
        config.captureElementInteractions = false
        config.captureSwiftUIElementInteractions = false
        config.captureAutocaptureElementText = false
        config.rageClickConfig.enabled = false
        // Nothing left needs swizzling, and this keeps PostHog out of the app's notification delegate.
        config.enableSwizzling = false
        config.capturePushNotificationSubscriptions = false
        config.capturePushNotificationOpened = false
        config.sessionReplay = false
        config.surveys = false
        config.errorTrackingConfig.autoCapture = false
        // Anonymous: no person records, no feature flags (the flags request is the only one that
        // carries the SDK's device ID), no location lookup from the IP address.
        config.personProfiles = .never
        config.preloadFeatureFlags = false
        config.sendFeatureFlagEvent = false
        config.disableGeoIp = true
        config.optOut = !sharing
        config.setBeforeSend { event in
            Self.applyPolicy(to: event)
        }
#if DEBUG
        config.flushAt = 1
#endif

        PostHogSDK.shared.setup(config)
        isConfigured = true
        // The SDK saves its own opt-out state; the person's answer is the source of truth.
        if sharing {
            PostHogSDK.shared.optIn()
        } else {
            PostHogSDK.shared.optOut()
        }

        planTierChange = RevenueCatService.shared.$planTier
            .removeDuplicates()
            .sink { [weak self] tier in
                self?.planTier = tier
                self?.registerSuperProperties()
            }
        registerSuperProperties()
        debugLog("🟢 Analytics ready (\(Self.projectName)), sharing: \(sharing)")
    }

    // MARK: - Sharing

    /// The sign-in screen's note has appeared. Sharing starts now, unless it was switched off.
    func noticeShown() {
        guard !UsageSharing.noticeShown() else { return }
        UsageSharing.recordNoticeShown()
        applySharing(UsageSharing.isSharing())
    }

    /// The Settings toggle "Share anonymous usage data".
    func setSharing(_ sharing: Bool) {
        UsageSharing.record(sharing)
        applySharing(sharing)
    }

    private func applySharing(_ sharing: Bool) {
        guard sharing != isSharing else { return }
        isSharing = sharing
        guard isConfigured else { return }
        if sharing {
            PostHogSDK.shared.optIn()
            registerSuperProperties()
        } else {
            PostHogSDK.shared.optOut()
            // A new ID, so the time before opting out can't be joined to any time after.
            resetIdentity()
        }
    }

    // MARK: - Events

    func track(_ event: AnalyticsEvent) {
        guard isConfigured, isSharing else { return }
        PostHogSDK.shared.capture(event.name.rawValue, properties: event.payload)
    }

    /// Starts sending what's queued, without waiting.
    func flush() {
        guard isConfigured else { return }
        PostHogSDK.shared.flush()
    }

    /// Replaces this install's random ID, so one ID never spans two accounts. Call after sign-out
    /// and account deletion. Events already queued keep the ID they were captured with.
    func resetIdentity() {
        guard isConfigured else { return }
        PostHogSDK.shared.reset()
        registerSuperProperties()
    }

    // MARK: - Private

    private func registerSuperProperties() {
        guard isConfigured else { return }
        PostHogSDK.shared.register([AnalyticsEvent.Key.planTier.rawValue: planTier.rawValue])
    }

    private nonisolated static func applyPolicy(to event: PostHogEvent) -> PostHogEvent? {
        guard let result = AnalyticsPolicy.filter(event: event.event, properties: event.properties) else {
            debugLog("🚫 Analytics dropped event \(event.event)")
            return nil
        }
        event.properties = result.properties
#if DEBUG
        if !result.dropped.isEmpty {
            debugLog("✂️ Analytics removed from \(event.event): \(result.dropped.joined(separator: ", "))")
        }
        let line = result.properties
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        debugLog("📤 \(event.event) \(line)")
#endif
        return event
    }

    private static var projectName: String {
#if DEBUG
        "Anicca Debug"
#else
        "Anicca"
#endif
    }
}
