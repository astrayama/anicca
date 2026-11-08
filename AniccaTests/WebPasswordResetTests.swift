import XCTest

/// "Forgot password?" emails a link to the reset page on screenseiji.com, which works on any
/// device. The request leaves out the PKCE code challenge the Supabase SDK always adds: a PKCE
/// link carries only a code that the app on the requesting iPhone can exchange, so a web page
/// couldn't use it.
final class PasswordResetRequestTests: XCTestCase {

    private let project = URL(string: "https://project.supabase.co")!
    private let page = URL(string: "https://www.screenseiji.com/apps/anicca/reset-password")!

    private func request(email: String = "seeker@example.com") -> URLRequest {
        PasswordResetRequest.make(supabaseURL: project, apiKey: "sb_publishable_test", email: email, redirectTo: page)
    }

    private func body(of request: URLRequest) throws -> [String: Any] {
        let data = try XCTUnwrap(request.httpBody)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func testPostsToTheRecoverEndpointWithTheResetPageAsTheRedirect() throws {
        let request = request()
        XCTAssertEqual(request.httpMethod, "POST")
        let components = try XCTUnwrap(URLComponents(url: try XCTUnwrap(request.url), resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.host, "project.supabase.co")
        XCTAssertEqual(components.path, "/auth/v1/recover")
        XCTAssertEqual(components.queryItems, [URLQueryItem(name: "redirect_to", value: page.absoluteString)])
    }

    func testSendsTheProjectKeyAsJSON() {
        let request = request()
        XCTAssertEqual(request.value(forHTTPHeaderField: "apikey"), "sb_publishable_test")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testSendsOnlyTheEmailSoTheLinkWorksOnTheWeb() throws {
        XCTAssertEqual(try body(of: request()) as? [String: String], ["email": "seeker@example.com"])
    }

    func testTrimsSpacesAroundTheEmail() throws {
        XCTAssertEqual(try body(of: request(email: "  seeker@example.com \n"))["email"] as? String, "seeker@example.com")
    }

    func testSupabaseAcceptingTheRequestIsNoError() {
        XCTAssertNil(PasswordResetRequest.error(status: 200, body: Data("{}".utf8)))
    }

    func testAskingAgainTooSoonSaysToCheckTheInbox() {
        let body = Data(#"{"code":429,"error_code":"over_email_send_rate_limit","msg":"For security purposes, you can only request this after 52 seconds."}"#.utf8)
        XCTAssertEqual(PasswordResetRequest.error(status: 429, body: body), .authFailed(Strings.Auth.resetTooSoon))
    }

    func testAnEmailSupabaseRejectsAsksForAValidOne() {
        let body = Data(#"{"code":400,"error_code":"email_address_invalid","msg":"Email address \"x@y\" is invalid"}"#.utf8)
        XCTAssertEqual(PasswordResetRequest.error(status: 400, body: body), .authFailed(Strings.Auth.invalidEmail))
    }

    func testAnyOtherFailureGetsTheGenericMessage() {
        let error = PasswordResetRequest.error(status: 500, body: Data("<html>".utf8))
        XCTAssertEqual(error?.errorDescription, Strings.Errors.generic)
    }
}

final class PasswordResetPageTests: XCTestCase {

    func testResetEmailsOpenTheResetPageOnScreenseiji() {
        XCTAssertEqual(AppConfig.passwordResetPageURL.absoluteString, "https://www.screenseiji.com/apps/anicca/reset-password")
    }

    func testTheResetPageIsOnTheSiteURLHostSupabaseAlreadyAllows() {
        XCTAssertEqual(AppConfig.passwordResetPageURL.host, "www.screenseiji.com")
    }
}

/// The reset page's "Open Anicca" button links to `<scheme>://password-updated`, which opens the
/// sign-in screen with a note instead of being treated as an email link.
final class PasswordUpdatedLinkTests: XCTestCase {

    private let appURL = URL(string: "com.screenseiji.anicca://password-updated")!

    func testRecognisesTheResetPagesLinkBackIntoTheApp() {
        XCTAssertTrue(AuthLink.isPasswordUpdatedNotice(appURL, appURL: appURL))
    }

    func testEmailLinksAreNotTheNotice() {
        let callback = URL(string: "com.screenseiji.anicca://auth-callback?code=abc")!
        XCTAssertFalse(AuthLink.isPasswordUpdatedNotice(callback, appURL: appURL))
    }

    func testOtherAppsLinksAreNotTheNotice() {
        let google = URL(string: "com.googleusercontent.apps.123://password-updated")!
        XCTAssertFalse(AuthLink.isPasswordUpdatedNotice(google, appURL: appURL))
    }

    func testTheNoticeShowsOnlyRightAfterTheReset() {
        let updated = Date(timeIntervalSince1970: 1_800_000_000)
        XCTAssertTrue(AuthLink.isFreshPasswordUpdate(at: updated, now: updated.addingTimeInterval(60)))
        XCTAssertFalse(AuthLink.isFreshPasswordUpdate(at: updated, now: updated.addingTimeInterval(11 * 60)))
    }
}
