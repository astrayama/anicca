import XCTest

/// Password reset links come back through the same `auth-callback` URL as sign-up confirmations
/// (it's the one URL on the Supabase allow list). With PKCE the redirect carries only `?code=`, so
/// the app tells a reset apart by the `amr` claim Supabase puts in the new session's access token.
final class AuthLinkTests: XCTestCase {

    private let callback = URL(string: "com.screenseiji.anicca://auth-callback?code=7c2f6b1e-0d4a-4a8e-9f61-5b0c1d2e3f4a")!

    /// A Supabase-shaped access token around `payload` (base64url, no padding, as in a real JWT).
    private func accessToken(payload: String) -> String {
        let encoded = Data(payload.utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\(encoded).c2lnbmF0dXJl"
    }

    // "???>>>" makes the payload encode with "_" and "-", and its length needs padding back.
    private var recoveryToken: String {
        accessToken(payload: #"{"amr":[{"method":"recovery","timestamp":1762531200}],"aud":"authenticated","note":"???>>>"}"#)
    }

    func testRecoveryFixtureUsesTheURLSafeAlphabetWithoutPadding() {
        let payload = recoveryToken.split(separator: ".")[1]
        XCTAssertTrue(payload.contains("_") && payload.contains("-"))
        XCTAssertNotEqual(payload.count % 4, 0)
    }

    func testReadsTheAuthenticationMethodsFromTheAccessToken() {
        XCTAssertEqual(AuthLink.authenticationMethods(inAccessToken: recoveryToken), ["recovery"])
    }

    func testAResetLinkSessionIsAPasswordRecovery() {
        XCTAssertTrue(AuthLink.isPasswordRecovery(url: callback, accessToken: recoveryToken))
    }

    func testASignUpConfirmationIsNotAPasswordRecovery() {
        let token = accessToken(payload: #"{"amr":[{"method":"email/signup","timestamp":1762531200}]}"#)
        XCTAssertFalse(AuthLink.isPasswordRecovery(url: callback, accessToken: token))
    }

    func testAPasswordSignInIsNotAPasswordRecovery() {
        let token = accessToken(payload: #"{"amr":[{"method":"password","timestamp":1762531200}]}"#)
        XCTAssertFalse(AuthLink.isPasswordRecovery(url: callback, accessToken: token))
    }

    func testRecoveryAnywhereInTheMethodListCounts() {
        let token = accessToken(payload: #"{"amr":[{"method":"token_refresh","timestamp":1762531300},{"method":"recovery","timestamp":1762531200}]}"#)
        XCTAssertTrue(AuthLink.isPasswordRecovery(url: callback, accessToken: token))
    }

    /// Implicit-flow links carry the type in the fragment, and their sessions say "otp".
    func testAnImplicitFlowRecoveryLinkCountsWithoutTheClaim() {
        let url = URL(string: "com.screenseiji.anicca://auth-callback#access_token=abc&refresh_token=def&type=recovery")!
        XCTAssertTrue(AuthLink.isPasswordRecovery(url: url, accessToken: "not-a-jwt"))
    }

    func testATypeInTheQueryCountsToo() {
        let url = URL(string: "com.screenseiji.anicca://auth-callback?code=abc&type=recovery")!
        XCTAssertTrue(AuthLink.isPasswordRecovery(url: url, accessToken: "not-a-jwt"))
    }

    func testUnreadableTokensHaveNoMethods() {
        XCTAssertEqual(AuthLink.authenticationMethods(inAccessToken: ""), [])
        XCTAssertEqual(AuthLink.authenticationMethods(inAccessToken: "not-a-jwt"), [])
        XCTAssertEqual(AuthLink.authenticationMethods(inAccessToken: "a.%%%.c"), [])
        XCTAssertEqual(AuthLink.authenticationMethods(inAccessToken: accessToken(payload: "[1,2]")), [])
        XCTAssertEqual(AuthLink.authenticationMethods(inAccessToken: accessToken(payload: #"{"sub":"x"}"#)), [])
    }
}

final class PasswordRulesTests: XCTestCase {

    func testAcceptsAMatchingPasswordOfTheMinimumLength() {
        let problems = PasswordRules.checkNewPassword("12345678", confirmation: "12345678")
        XCTAssertTrue(problems.isEmpty)
        XCTAssertEqual(problems, .init(password: nil, confirmation: nil))
    }

    func testRejectsAShortPassword() {
        let problems = PasswordRules.checkNewPassword("1234567", confirmation: "1234567")
        XCTAssertEqual(problems, .init(password: Strings.Auth.passwordTooShort, confirmation: nil))
        XCTAssertFalse(problems.isEmpty)
    }

    func testRejectsAMismatchedConfirmation() {
        let problems = PasswordRules.checkNewPassword("correct horse", confirmation: "correct house")
        XCTAssertEqual(problems, .init(password: nil, confirmation: Strings.Auth.passwordsDoNotMatch))
    }

    func testReportsBothProblemsAtOnce() {
        let problems = PasswordRules.checkNewPassword("short", confirmation: "")
        XCTAssertEqual(problems, .init(password: Strings.Auth.passwordTooShort, confirmation: Strings.Auth.passwordsDoNotMatch))
    }

    func testTheSignUpRuleUsesTheSameMinimum() {
        XCTAssertEqual(PasswordRules.minimumLength, 8)
    }
}

@MainActor
final class SetNewPasswordViewModelTests: XCTestCase {

    @MainActor
    private final class SaveRecorder {
        var passwords: [String] = []
        var error: Error?

        func save(_ password: String) async throws {
            passwords.append(password)
            if let error { throw error }
        }
    }

    private var recorder: SaveRecorder!
    private var viewModel: SetNewPasswordViewModel!

    override func setUp() async throws {
        let recorder = SaveRecorder()
        self.recorder = recorder
        viewModel = SetNewPasswordViewModel(save: { try await recorder.save($0) })
    }

    override func tearDown() async throws {
        viewModel = nil
        recorder = nil
    }

    func testSavesAValidPasswordOnce() async {
        viewModel.password = "a new password"
        viewModel.confirmation = "a new password"
        await viewModel.submit()
        XCTAssertEqual(recorder.passwords, ["a new password"])
        XCTAssertNil(viewModel.passwordError)
        XCTAssertNil(viewModel.confirmationError)
        XCTAssertNil(viewModel.generalError)
        XCTAssertFalse(viewModel.isWorking)
    }

    func testDoesNotSaveAnInvalidPassword() async {
        viewModel.password = "short"
        viewModel.confirmation = "shorter"
        await viewModel.submit()
        XCTAssertEqual(recorder.passwords, [])
        XCTAssertEqual(viewModel.passwordError, Strings.Auth.passwordTooShort)
        XCTAssertEqual(viewModel.confirmationError, Strings.Auth.passwordsDoNotMatch)
    }

    func testShowsTheMessageOfAnAppError() async {
        recorder.error = AppError.authFailed(Strings.Auth.newPasswordSameAsOld)
        viewModel.password = "my old password"
        viewModel.confirmation = "my old password"
        await viewModel.submit()
        XCTAssertEqual(viewModel.generalError, Strings.Auth.newPasswordSameAsOld)
        XCTAssertFalse(viewModel.isWorking)
    }

    func testShowsTheGenericMessageForAnyOtherError() async {
        recorder.error = URLError(.badServerResponse)
        viewModel.password = "a new password"
        viewModel.confirmation = "a new password"
        await viewModel.submit()
        XCTAssertEqual(viewModel.generalError, Strings.Errors.generic)
    }

    func testFixingTheInputClearsTheOldErrors() async {
        recorder.error = AppError.network
        viewModel.password = "short"
        viewModel.confirmation = "short"
        await viewModel.submit()
        viewModel.password = "a new password"
        viewModel.confirmation = "a new password"
        await viewModel.submit()
        XCTAssertNil(viewModel.passwordError)
        XCTAssertEqual(viewModel.generalError, Strings.Errors.network)

        recorder.error = nil
        await viewModel.submit()
        XCTAssertNil(viewModel.generalError)
        XCTAssertEqual(recorder.passwords.count, 2)
    }
}

/// What Supabase says when `updateUser(password:)` refuses the new password.
final class PasswordErrorMappingTests: XCTestCase {

    private func supabaseError(_ message: String) -> NSError {
        NSError(domain: "Auth.AuthError", code: 422, userInfo: [NSLocalizedDescriptionKey: message])
    }

    func testTheSamePasswordAsBeforeGetsItsOwnMessage() {
        let error = supabaseError("New password should be different from the old password.")
        XCTAssertEqual(SupabaseErrorMapper.map(error), .authFailed(Strings.Auth.newPasswordSameAsOld))
    }

    func testThePasswordRulesOfTheProjectAreShownAsTheServerWordsThem() {
        let message = "Password should contain at least one character of each: abcdefghijklmnopqrstuvwxyz, 0123456789."
        XCTAssertEqual(SupabaseErrorMapper.map(supabaseError(message)), .authFailed(message))
    }

    func testALeakedPasswordIsShownAsTheServerWordsIt() {
        let message = "Password is known to be weak and easy to guess, please choose a different one."
        XCTAssertEqual(SupabaseErrorMapper.map(supabaseError(message)), .authFailed(message))
    }

    func testSignInErrorsStillMapAsBefore() {
        XCTAssertEqual(
            SupabaseErrorMapper.map(supabaseError("Invalid login credentials")),
            .authFailed("Email or password is incorrect.")
        )
        XCTAssertEqual(SupabaseErrorMapper.map(supabaseError("Something unexpected")), .unknown(Strings.Errors.generic))
    }
}
