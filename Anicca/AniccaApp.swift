import SwiftUI
import SwiftData
import UserNotifications
import UIKit
import GoogleSignIn

enum RootRoute: Equatable {
    case splash
    case auth
    case onboarding
    case main
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var route: RootRoute = .splash
    @Published var selectedTab: MainTab = .home

    func routeForCurrentState() {
        if AuthService.shared.isAuthenticated {
            let done = UserDefaults.standard.bool(forKey: AppConfig.onboardingCompleteKey)
            route = done ? .main : .onboarding
        } else {
            route = .auth
        }
    }
}

@main
struct AniccaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var auth = AuthService.shared
    @StateObject private var entitlements = EntitlementManager.shared
    @StateObject private var revenueCat = RevenueCatService.shared
    @StateObject private var router = AppRouter()

    let modelContainer: ModelContainer

    init() {
        RevenueCatService.shared.configure(apiKey: AppConfig.revenueCatAPIKey)
        do {
            let schema = Schema([CheckIn.self, EmotionEntry.self, UserProfile.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            assertionFailure("Failed to initialize ModelContainer: \(error)")
            // Unreachable in production: SwiftData container init only fails for catastrophic disk errors.
            fatalError("Could not initialize SwiftData container")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch router.route {
                case .splash:
                    SplashScreen {
                        Task { await bootstrap() }
                    }
                case .auth:
                    AuthView()
                case .onboarding:
                    OnboardingView {
                        router.route = .main
                    }
                case .main:
                    MainTabView(selectedTab: $router.selectedTab)
                }
            }
            .environmentObject(auth)
            .environmentObject(entitlements)
            .environmentObject(revenueCat)
            .environmentObject(router)
            .preferredColorScheme(.light)
            // A password-reset link signed the user in: they choose a new password before anything
            // else, whichever route is underneath (the link can arrive during the splash screen).
            .fullScreenCover(isPresented: Binding(get: { auth.passwordResetEmail != nil }, set: { _ in })) {
                SetNewPasswordView()
                    .environmentObject(auth)
                    .preferredColorScheme(.light)
            }
            .onReceive(auth.$isAuthenticated) { authenticated in
                if authenticated {
                    if router.route == .auth || router.route == .splash {
                        let done = UserDefaults.standard.bool(forKey: AppConfig.onboardingCompleteKey)
                        router.route = done ? .main : .onboarding
                    }
                    // Links purchases to this account; the tier (and its Supabase copy) updates
                    // through RevenueCatService, which EntitlementManager mirrors.
                    Task {
                        if let id = auth.currentUser?.id {
                            await revenueCat.login(userId: id)
                        }
                    }
                } else {
                    if router.route == .main || router.route == .onboarding {
                        router.route = .auth
                    }
                    Task { await revenueCat.logout() }
                }
            }
            .onAppear {
                CheckInService.shared.setContext(modelContainer.mainContext)
                appDelegate.router = router
                UNUserNotificationCenter.current().delegate = appDelegate
            }
            .onChange(of: scenePhase) { _, newPhase in
                handleScene(newPhase)
            }
            .modelContainer(modelContainer)
            .onOpenURL { url in
                if AuthLink.isPasswordUpdatedNotice(url) {
                    // The reset page's "Open Anicca" button, after a new password was saved there.
                    auth.passwordWasUpdated()
                } else if url.scheme == AppConfig.authCallbackURL.scheme, url.host == AppConfig.authCallbackURL.host {
                    // Supabase email links: sign-up confirmations (and resets from older builds).
                    Task { await auth.handleAuthCallback(url) }
                } else {
                    GIDSignIn.sharedInstance.handle(url)
                }
            }
        }
    }

    private func bootstrap() async {
        await auth.restoreSession()
        await revenueCat.checkEntitlement()
        NotificationService.shared.clearBadge()
        await CheckInService.shared.retryUnsyncedCheckIns()
        router.routeForCurrentState()
    }

    private func handleScene(_ phase: ScenePhase) {
        switch phase {
        case .active:
            Task {
                NotificationService.shared.clearBadge()
                await revenueCat.checkEntitlement()
                await CheckInService.shared.retryUnsyncedCheckIns()
            }
        default:
            break
        }
    }
}

// MARK: - App Delegate

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    weak var router: AppRouter?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if !AppConfig.googleClientID.isEmpty {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: AppConfig.googleClientID)
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: Notifications

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        if let deep = userInfo["deep_link"] as? String, deep == "log" {
            await MainActor.run {
                router?.selectedTab = .log
                if router?.route != .main {
                    router?.route = .main
                }
            }
        }
    }
}
