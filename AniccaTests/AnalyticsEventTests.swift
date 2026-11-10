import XCTest

/// Locks in what Anicca's analytics may send (decided Nov 8 2026): anonymous counts and categories
/// only, never journal content, and nothing until the person says Yes.
final class AnalyticsEventTests: XCTestCase {

    private let context = PurchaseContext(plan: .pro, interval: .annual, source: .logLimit)

    /// One of every event. `testEveryEventNameHasASample` fails if a new case isn't added here.
    private var samples: [AnalyticsEvent] {
        [
            .onboardingCompleted(remindersEnabled: true, skippedIntro: false),
            .signedUp(method: .email, needsEmailConfirmation: true),
            .signedIn(method: .apple),
            .checkInCreated(inputMethod: .mixed, usedMapMyFeelings: true, emotionCount: 3, hasNote: true, checkInsThisMonth: 12, isFirstCheckIn: false),
            .mapMyFeelingsUsed(result: .noMatch, addedCount: 0),
            .freeLimitReached(limit: 30),
            .paywallViewed(source: .insightsReflection, plansLoaded: true),
            .purchaseStarted(context),
            .purchaseCompleted(context),
            .purchaseCancelled(context),
            .purchaseFailed(context, reason: .network),
            .purchasesRestored(result: .nothingToRestore, source: .settingsUpgrade),
            .weeklyReflectionViewed(state: .locked),
            .exportCreated(format: .pdf, checkInCount: 40),
            .reminderEnabled(source: .onboarding),
            .reminderDisabled,
            .reminderPermissionDenied(source: .settings),
            .signedOut,
            .accountDeleted(method: .google)
        ]
    }

    // MARK: - Names and keys

    func testEveryEventNameHasASample() {
        XCTAssertEqual(Set(samples.map(\.name)), Set(AnalyticsEvent.Name.allCases))
    }

    func testNamesAndKeysAreSnakeCase() {
        let snakeCase = /^[a-z]+(_[a-z]+)*$/
        for name in AnalyticsEvent.Name.allCases {
            XCTAssertNotNil(name.rawValue.wholeMatch(of: snakeCase), name.rawValue)
        }
        for key in AnalyticsEvent.Key.allCases {
            XCTAssertNotNil(key.rawValue.wholeMatch(of: snakeCase), key.rawValue)
        }
    }

    func testNoAppKeyLooksLikeContent() {
        // None of these may ever become a property: they'd carry what someone wrote or felt.
        let forbidden = ["text", "query", "note", "emotion", "emotion_name", "word", "words", "center",
                         "energy_center", "intensity", "reflection", "name", "display_name", "email",
                         "user_id", "price", "reminder_time", "url"]
        let keys = Set(AnalyticsEvent.Key.allCases.map(\.rawValue))
        for word in forbidden {
            XCTAssertFalse(keys.contains(word), "\(word) must not be an analytics property")
        }
    }

    // MARK: - Payloads

    func testPayloadsHoldOnlyBoolsIntsAndKnownTokens() {
        for event in samples {
            for (key, value) in event.properties {
                switch value {
                case .bool, .int:
                    break
                case .token(let token):
                    XCTAssertNotNil(token.wholeMatch(of: /^[a-z]+(_[a-z]+)*$/), "\(event.name.rawValue).\(key.rawValue) = \(token)")
                }
            }
        }
    }

    func testCheckInPayload() {
        let event = AnalyticsEvent.checkInCreated(
            inputMethod: .typed, usedMapMyFeelings: true, emotionCount: 2,
            hasNote: false, checkInsThisMonth: 5, isFirstCheckIn: true
        )
        XCTAssertEqual(event.name.rawValue, "checkin_created")
        XCTAssertEqual(event.properties, [
            .inputMethod: .token("typed"),
            .usedMapMyFeelings: .bool(true),
            .emotionCount: .int(2),
            .hasNote: .bool(false),
            .checkInsThisMonth: .int(5),
            .isFirstCheckIn: .bool(true)
        ])
    }

    func testPurchaseFailurePayloadHasAReasonNotAMessage() {
        let event = AnalyticsEvent.purchaseFailed(context, reason: .store)
        XCTAssertEqual(event.properties, [
            .plan: .token("pro"), .interval: .token("annual"), .source: .token("log_limit"), .reason: .token("store")
        ])
    }

    func testPayloadUsesRawKeyNames() {
        let payload = AnalyticsEvent.paywallViewed(source: .homeSuggestion, plansLoaded: false).payload
        XCTAssertEqual(payload["source"] as? String, "home_suggestion")
        XCTAssertEqual(payload["plans_loaded"] as? Bool, false)
        XCTAssertEqual(payload.count, 2)
    }

    // MARK: - New account detection

    func testAccountCreatedJustNowIsNew() {
        let now = Date()
        XCTAssertTrue(AnalyticsEvent.isNewAccount(createdAt: now.addingTimeInterval(-5), now: now))
    }

    func testOlderAccountIsNotNew() {
        let now = Date()
        XCTAssertFalse(AnalyticsEvent.isNewAccount(createdAt: now.addingTimeInterval(-3600), now: now))
    }

    // MARK: - Before-send policy

    func testPolicyKeepsAppEventsAndAllowedKeys() {
        let result = AnalyticsPolicy.filter(event: "checkin_created", properties: [
            "emotion_count": 2, "plan_tier": "free", "$os_version": "26.5", "distinct_id": "0193-abc"
        ])
        XCTAssertEqual(result?.properties.count, 4)
        XCTAssertEqual(result?.dropped, [])
    }

    func testPolicyDropsUnknownEvents() {
        XCTAssertNil(AnalyticsPolicy.filter(event: "$autocapture", properties: [:]))
        XCTAssertNil(AnalyticsPolicy.filter(event: "$screen", properties: [:]))
        XCTAssertNil(AnalyticsPolicy.filter(event: "Deep Link Opened", properties: ["url": "x"]))
        XCTAssertNil(AnalyticsPolicy.filter(event: "$exception", properties: [:]))
    }

    func testPolicyRemovesContentAndUnknownKeys() {
        let result = AnalyticsPolicy.filter(event: "checkin_created", properties: [
            "emotion_count": 2,
            "note": "I feel zqcanary4417",
            "$screen_name": "LogView",
            "$elements_chain": "button:text=\"anxious\"",
            "url": "com.screenseiji.anicca://auth-callback#access_token=secret"
        ])
        XCTAssertEqual(result?.properties.keys.sorted(), ["emotion_count"])
        XCTAssertEqual(result?.dropped, ["$elements_chain", "$screen_name", "note", "url"])
    }

    func testPolicyRemovesLongStringsEvenUnderAllowedKeys() {
        let long = String(repeating: "a", count: 200)
        let result = AnalyticsPolicy.filter(event: "signed_in", properties: ["method": long])
        XCTAssertEqual(result?.properties.count, 0)
    }

    func testPolicyKeepsLifecycleEventsWithTheirOwnKeysOnly() {
        let result = AnalyticsPolicy.filter(event: "Application Opened", properties: [
            "from_background": false, "version": "1.0.0", "build": 1, "url": "anicca://x", "emotion_count": 3
        ])
        XCTAssertEqual(result?.properties.keys.sorted(), ["build", "from_background", "version"])
    }

    // MARK: - Sharing (on by default, after the sign-in note)

    private func freshDefaults(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    func testNothingIsSharedBeforeTheNoteHasBeenShown() {
        let defaults = freshDefaults(#function)
        XCTAssertFalse(UsageSharing.noticeShown(in: defaults))
        XCTAssertFalse(UsageSharing.isSharing(in: defaults))
    }

    func testSharingIsOnByDefaultOnceTheNoteHasBeenShown() {
        let defaults = freshDefaults(#function)
        UsageSharing.recordNoticeShown(in: defaults)
        XCTAssertTrue(UsageSharing.isSharing(in: defaults))
    }

    func testSwitchingItOffInSettingsWins() {
        let defaults = freshDefaults(#function)
        UsageSharing.recordNoticeShown(in: defaults)
        UsageSharing.record(false, in: defaults)
        XCTAssertFalse(UsageSharing.isSharing(in: defaults))
        XCTAssertEqual(UsageSharing.explicitChoice(in: defaults), false)
    }

    func testSwitchingItOnInSettingsWorksEvenBeforeTheNote() {
        let defaults = freshDefaults(#function)
        UsageSharing.record(true, in: defaults)
        XCTAssertTrue(UsageSharing.isSharing(in: defaults))
    }

    // MARK: - PostHog key per build

    func testDebugUsesOnlyTheDebugKey() {
        XCTAssertEqual(PostHogKey.select(debugKey: "phc_debug", releaseKey: "phc_prod", isDebugBuild: true), "phc_debug")
        XCTAssertNil(PostHogKey.select(debugKey: "", releaseKey: "phc_prod", isDebugBuild: true))
    }

    func testReleaseUsesOnlyTheProductionKey() {
        XCTAssertEqual(PostHogKey.select(debugKey: "phc_debug", releaseKey: "phc_prod", isDebugBuild: false), "phc_prod")
        XCTAssertNil(PostHogKey.select(debugKey: "phc_debug", releaseKey: " ", isDebugBuild: false))
    }

    func testPlaceholdersAreNotKeys() {
        XCTAssertNil(PostHogKey.select(debugKey: "YOUR_POSTHOG_KEY", releaseKey: "", isDebugBuild: true))
    }
}
