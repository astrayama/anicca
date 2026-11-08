import Foundation

/// The request behind "Forgot password?". Supabase emails a link to the reset page on
/// screenseiji.com (`AppConfig.passwordResetPageURL`), where the user chooses a new password on
/// whatever device they read the email on, then signs in here with it.
///
/// It's sent without the Supabase SDK on purpose: the SDK always adds a PKCE code challenge, and
/// a PKCE link carries only a code that this app, on this iPhone, can exchange. Without one,
/// Supabase sends the browser to the page with a one-time session the page can use.
enum PasswordResetRequest {
    static func make(supabaseURL: URL, apiKey: String, email: String, redirectTo: URL) -> URLRequest {
        var components = URLComponents(
            url: supabaseURL.appendingPathComponent("auth/v1/recover"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "redirect_to", value: redirectTo.absoluteString)]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        request.httpBody = try? JSONEncoder().encode(["email": trimmed])
        return request
    }

    /// What to tell the user about Supabase's answer, or nil if it accepted the request. (It
    /// accepts unknown emails too, so the app never reveals who has an account.)
    static func error(status: Int, body: Data) -> AppError? {
        guard !(200..<300).contains(status) else { return nil }
        let code = (try? JSONDecoder().decode(ErrorBody.self, from: body))?.errorCode ?? ""
        if status == 429 || code.hasPrefix("over_") {
            return .authFailed(Strings.Auth.resetTooSoon)
        }
        if code == "email_address_invalid" || code == "validation_failed" {
            return .authFailed(Strings.Auth.invalidEmail)
        }
        return .unknown("")
    }

    private struct ErrorBody: Decodable {
        let errorCode: String?

        enum CodingKeys: String, CodingKey {
            case errorCode = "error_code"
        }
    }
}
