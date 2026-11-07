import Foundation
import Supabase
import AuthenticationServices
import CryptoKit
import GoogleSignIn
import UIKit

enum AuthProvider: String {
    case apple = "apple"
    case google = "google"
    case email = "email"
}

@MainActor
final class AuthService: NSObject, ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: UserProfile?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var authProvider: AuthProvider?

    private var pendingDeleteContinuation: CheckedContinuation<String, Error>?

    private let client: SupabaseClient
    private var appleNonce: String?

    private override init() {
        self.client = SupabaseConfig.shared.client
        super.init()
    }

    // MARK: - Session

    func restoreSession() async {
        do {
            let session = try await client.auth.session
            await loadProfile(
                userId: UserID.normalized(session.user.id),
                email: session.user.email ?? "",
                displayName: session.user.userMetadata["display_name"]?.stringValue
            )

            // Detect auth provider (appMetadata values are AnyJSON, not String)
            switch session.user.appMetadata["provider"]?.stringValue {
            case "apple": self.authProvider = .apple
            case "google": self.authProvider = .google
            default: self.authProvider = .email
            }

            self.isAuthenticated = true
        } catch {
            self.isAuthenticated = false
            self.currentUser = nil
            self.authProvider = nil
        }
    }

    // MARK: - Email/Password

    enum EmailSignUpResult {
        case signedIn
        /// The project requires email confirmation: there is no session until the user opens the
        /// link, which comes back through `handleAuthCallback(_:)`.
        case confirmationEmailSent
    }

    func signUpWithEmail(email: String, password: String, displayName: String) async throws -> EmailSignUpResult {
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["display_name": .string(displayName)],
                redirectTo: AppConfig.authCallbackURL
            )
            // Without a session the profile insert would be rejected by RLS, so it waits until
            // the first signed-in load (see `loadProfile`).
            guard let session = response.session else { return .confirmationEmailSent }
            let userId = UserID.normalized(session.user.id)
            try await createProfile(userId: userId, email: email, displayName: displayName)
            await loadProfile(userId: userId, email: email)
            self.isAuthenticated = true
            return .signedIn
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }

    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            await loadProfile(
                userId: UserID.normalized(session.user.id),
                email: session.user.email ?? email,
                displayName: session.user.userMetadata["display_name"]?.stringValue
            )
            self.isAuthenticated = true
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }

    /// Finishes sign-up when the user opens the confirmation link from their email.
    func handleAuthCallback(_ url: URL) async {
        do {
            let session = try await client.auth.session(from: url)
            await loadProfile(
                userId: UserID.normalized(session.user.id),
                email: session.user.email ?? "",
                displayName: session.user.userMetadata["display_name"]?.stringValue
            )
            self.authProvider = .email
            self.isAuthenticated = true
        } catch {
            debugLog("🔴 AuthService.handleAuthCallback failed: \(error)")
            // Already signed in (an old link opened again): nothing to tell the user.
            if !isAuthenticated {
                self.errorMessage = Strings.Auth.confirmLinkFailed
            }
        }
    }

    func resetPassword(email: String) async throws {
        do {
            try await client.auth.resetPasswordForEmail(email)
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }

    // MARK: - Apple Sign In

    /// Configures the SignInWithAppleButton request with scopes and a fresh nonce.
    func prepareAppleSignIn(request: ASAuthorizationAppleIDRequest) {
        let nonce = Self.randomNonceString()
        self.appleNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)
    }

    /// Exchanges the credential returned by SignInWithAppleButton for a Supabase session.
    func signInWithApple(identityToken: String, email credentialEmail: String?, fullName: PersonNameComponents?) async throws {
        guard let nonce = appleNonce else {
            throw AppError.authFailed("Apple Sign In failed.")
        }
        appleNonce = nil
        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: .init(provider: .apple, idToken: identityToken, nonce: nonce)
            )
            let email = session.user.email ?? credentialEmail ?? ""
            let displayName: String? = fullName.flatMap { name in
                let formatted = PersonNameComponentsFormatter().string(from: name)
                return formatted.isEmpty ? nil : formatted
            }
            let userId = UserID.normalized(session.user.id)
            try? await ensureProfileExists(userId: userId, email: email, displayName: displayName)
            await loadProfile(userId: userId, email: email)
            self.isAuthenticated = true
            self.authProvider = .apple
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }

    // MARK: - Google Sign In

    func signInWithGoogle(presenting: UIViewController) async throws {
        if GIDSignIn.sharedInstance.configuration == nil, !AppConfig.googleClientID.isEmpty {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: AppConfig.googleClientID)
        }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AppError.authFailed("Could not obtain Google ID token.")
            }
            let accessToken = result.user.accessToken.tokenString
            let session = try await client.auth.signInWithIdToken(
                credentials: .init(provider: .google, idToken: idToken, accessToken: accessToken)
            )
            let email = session.user.email ?? result.user.profile?.email ?? ""
            let displayName = result.user.profile?.name
            let userId = UserID.normalized(session.user.id)
            try? await ensureProfileExists(userId: userId, email: email, displayName: displayName)
            await loadProfile(userId: userId, email: email)
            self.isAuthenticated = true
        } catch {
            debugLog("🔴 Google Sign-in Error: \(error)")
            throw SupabaseErrorMapper.map(error)
        }
    }

    // MARK: - Re-authentication

    func reauthenticateWithApple(presentationContext: ASPresentationAnchor) async throws -> String {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]
        request.nonce = Self.sha256(Self.randomNonceString())

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            self.pendingDeleteContinuation = continuation
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    func reauthenticateWithGoogle(presenting: UIViewController) async throws -> String {
        if GIDSignIn.sharedInstance.configuration == nil, !AppConfig.googleClientID.isEmpty {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: AppConfig.googleClientID)
        }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AppError.authFailed("Could not obtain Google ID token.")
            }
            return idToken
        } catch {
            debugLog("🔴 Google re-authentication error: \(error)")
            throw SupabaseErrorMapper.map(error)
        }
    }

    func validateEmailPassword(_ password: String) async throws {
        guard let email = currentUser?.email else { throw AppError.notAuthenticated }
        do {
            _ = try await client.auth.signIn(email: email, password: password)
        } catch {
            throw AppError.authFailed("Incorrect password.")
        }
    }

    // MARK: - Sign Out

    func signOut() async throws {
        do {
            try await client.auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }

    // MARK: - Delete Account

    func deleteAccount(
        withAppleIDToken idToken: String? = nil,
        googleIDToken: String? = nil,
        emailPassword: String? = nil
    ) async throws {
        guard currentUser != nil else { throw AppError.notAuthenticated }
        guard let session = try? await client.auth.session else { throw AppError.notAuthenticated }

        let userId = UserID.normalized(session.user.id)
        let jwt = session.accessToken

        struct DeleteAccountPayload: Encodable {
            let userId: String
            let appleIDToken: String?
            let googleIDToken: String?
            let emailPassword: String?
        }

        do {
            _ = try await client.functions.invoke(
                "delete-account",
                options: FunctionInvokeOptions(
                    headers: ["Authorization": "Bearer \(jwt)"],
                    body: DeleteAccountPayload(
                        userId: userId,
                        appleIDToken: idToken,
                        googleIDToken: googleIDToken,
                        emailPassword: emailPassword
                    )
                )
            )

            try await client.auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            self.authProvider = nil
        } catch {
            debugLog("🔴 AuthService.deleteAccount failed: \(error)")
            throw SupabaseErrorMapper.map(error)
        }
    }

    // MARK: - Profile management

    private func createProfile(userId: String, email: String, displayName: String) async throws {
        let insert = UserProfileInsert(
            id: userId,
            email: email,
            display_name: displayName.isEmpty ? nil : displayName,
            plan_tier: PlanTier.free.rawValue
        )
        try await client.from("profiles").upsert(insert).execute()
    }

    private func ensureProfileExists(userId: String, email: String, displayName: String?) async throws {
        let insert = UserProfileInsert(
            id: userId,
            email: email,
            display_name: displayName,
            plan_tier: PlanTier.free.rawValue
        )
        do {
            try await client.from("profiles").upsert(insert, onConflict: "id").execute()
            debugLog("🟢 AuthService: Successfully ensured profile exists in Supabase.")
        } catch {
            debugLog("🔴 AuthService.ensureProfileExists failed: \(error)")
            throw error
        }
    }

    /// Loads the signed-in user's profile row. If it can't be read, the row may never have been
    /// created (email sign-ups that had to confirm first get no session, so they skip
    /// `createProfile`), so insert it without touching an existing row and try once more.
    private func loadProfile(userId: String, email: String, displayName: String? = nil) async {
        let userId = UserID.normalized(userId)
        do {
            self.currentUser = try await fetchProfile(userId: userId)
            debugLog("🟢 AuthService: Successfully loaded profile from Supabase for \(email).")
            return
        } catch {
            debugLog("🔴 AuthService.loadProfile failed: \(error). Creating the row if it's missing.")
        }
        do {
            let insert = UserProfileInsert(
                id: userId,
                email: email,
                display_name: displayName,
                plan_tier: PlanTier.free.rawValue
            )
            try await client.from("profiles")
                .upsert(insert, onConflict: "id", returning: .minimal, ignoreDuplicates: true)
                .execute()
            self.currentUser = try await fetchProfile(userId: userId)
        } catch {
            debugLog("🔴 AuthService.loadProfile retry failed: \(error). Falling back to synthesized local profile.")
            // Fallback: synthesize a local profile so the app still loads.
            self.currentUser = UserProfile(id: userId, email: email, displayName: displayName)
        }
    }

    private func fetchProfile(userId: String) async throws -> UserProfile {
        let row: UserProfileDTO = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value

        return UserProfile(row: row)
    }

    // MARK: - Updates

    func updateDisplayName(_ name: String) async {
        guard let userId = currentUser?.id else { return }
        var update = UserProfileUpdate()
        update.display_name = name
        do {
            try await client.from("profiles").update(update).eq("id", value: userId).execute()
            currentUser?.displayName = name
            debugLog("🟢 AuthService: Successfully updated display name to '\(name)' in Supabase.")
        } catch {
            debugLog("🔴 AuthService.updateDisplayName failed: \(error). Using local-only fallback.")
            // Silent — fall back to local
            currentUser?.displayName = name
        }
    }

    func updatePlanTier(_ tier: PlanTier) async {
        guard let userId = currentUser?.id else { return }
        var update = UserProfileUpdate()
        update.plan_tier = tier.rawValue
        do {
            try await client.from("profiles").update(update).eq("id", value: userId).execute()
            debugLog("🟢 AuthService: Successfully updated plan tier to '\(tier.rawValue)' in Supabase.")
        } catch {
            debugLog("🔴 AuthService.updatePlanTier failed: \(error)")
            // Silent — RevenueCat is source of truth so cache locally
        }
        currentUser?.planTier = tier
    }

    func updateReminderSettings(enabled: Bool, time: Date?) async {
        guard let userId = currentUser?.id else { return }
        var update = UserProfileUpdate()
        update.reminder_enabled = enabled
        update.reminder_time = time
        do {
            try await client.from("profiles").update(update).eq("id", value: userId).execute()
            debugLog("🟢 AuthService: Successfully updated reminder settings in Supabase.")
        } catch {
            debugLog("🔴 AuthService.updateReminderSettings failed: \(error)")
            // ignore — best effort
        }
        currentUser?.reminderEnabled = enabled
        currentUser?.reminderTime = time
    }

    func updateStreakStats(streak: Int, totalCheckIns: Int, lastDate: Date) async {
        guard let userId = currentUser?.id else { return }
        var update = UserProfileUpdate()
        update.check_in_streak = streak
        update.total_check_ins = totalCheckIns
        update.last_check_in_date = lastDate
        do {
            try await client.from("profiles").update(update).eq("id", value: userId).execute()
            debugLog("🟢 AuthService: Successfully updated streak/checkin stats in Supabase.")
        } catch {
            debugLog("🔴 AuthService.updateStreakStats failed: \(error)")
            // ignore — best effort
        }
        currentUser?.checkInStreak = streak
        currentUser?.totalCheckIns = totalCheckIns
        currentUser?.lastCheckInDate = lastDate
    }

    // MARK: - Apple Helpers

    private static func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            if status != errSecSuccess { continue }
            for random in randoms where remaining > 0 {
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Apple delegate

extension AuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        DispatchQueue.main.sync {
            UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow } ?? ASPresentationAnchor()
        }
    }

    // The ASAuthorizationController delegate serves only the delete-account
    // re-auth flow; interactive sign-in goes through SignInWithAppleButton.
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            guard
                let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let identityTokenData = appleCredential.identityToken,
                let identityToken = String(data: identityTokenData, encoding: .utf8)
            else {
                self.pendingDeleteContinuation?.resume(throwing: AppError.authFailed("Apple re-authentication failed."))
                self.pendingDeleteContinuation = nil
                return
            }
            self.pendingDeleteContinuation?.resume(returning: identityToken)
            self.pendingDeleteContinuation = nil
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            self.pendingDeleteContinuation?.resume(throwing: AppError.authFailed("Apple re-authentication was cancelled or failed."))
            self.pendingDeleteContinuation = nil
        }
    }
}
