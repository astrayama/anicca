import Foundation

/// Reads what an email link from Supabase brings back into the app. Sign-up confirmations and
/// password resets both return through `AppConfig.authCallbackURL` (the app's one entry on the
/// project's Redirect URLs list), so the URL alone doesn't say which kind of link it was.
enum AuthLink {
    /// True when the session made from `url` came from a password-reset email, so the user still
    /// has to choose a new password. The app uses PKCE, whose redirect carries only `?code=…`, and
    /// Supabase marks the session it issues for a reset code with `recovery` in the access token's
    /// `amr` claim. Implicit-flow links say `type=recovery` in the URL instead.
    static func isPasswordRecovery(url: URL, accessToken: String) -> Bool {
        parameters(in: url)["type"] == "recovery"
            || authenticationMethods(inAccessToken: accessToken).contains("recovery")
    }

    /// The `amr` methods ("password", "otp", "recovery", …) in a Supabase access token, or none if
    /// it can't be read. Only the payload is decoded: checking the signature is the server's job.
    static func authenticationMethods(inAccessToken token: String) -> [String] {
        let segments = token.split(separator: ".", omittingEmptySubsequences: false)
        guard segments.count == 3 else { return [] }
        var base64 = segments[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        guard
            let data = Data(base64Encoded: base64),
            let claims = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let amr = claims["amr"] as? [[String: Any]]
        else { return [] }
        return amr.compactMap { $0["method"] as? String }
    }

    /// Query and fragment parameters together: Supabase uses one or the other depending on the flow.
    private static func parameters(in url: URL) -> [String: String] {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var items = components?.queryItems ?? []
        if let fragment = components?.fragment {
            items += URLComponents(string: "?" + fragment)?.queryItems ?? []
        }
        let pairs = items.compactMap { item in item.value.map { (item.name, $0) } }
        return Dictionary(pairs, uniquingKeysWith: { first, _ in first })
    }
}
