import Foundation

/// The app's rules for a password the user picks, at sign-up or after a reset link. The Supabase
/// project can ask for more (required characters, leaked-password checks); those come back as
/// errors from the server (see `SupabaseErrorMapper`).
enum PasswordRules {
    static let minimumLength = 8

    struct NewPasswordProblems: Equatable {
        var password: String?
        var confirmation: String?

        var isEmpty: Bool { password == nil && confirmation == nil }
    }

    static func checkNewPassword(_ password: String, confirmation: String) -> NewPasswordProblems {
        NewPasswordProblems(
            password: password.count < minimumLength ? Strings.Auth.passwordTooShort : nil,
            confirmation: password == confirmation ? nil : Strings.Auth.passwordsDoNotMatch
        )
    }
}
