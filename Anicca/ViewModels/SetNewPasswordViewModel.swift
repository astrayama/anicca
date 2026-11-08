import Foundation
import Combine

/// The screen a password-reset link opens. Saving goes through `save` (`AuthService.setNewPassword`
/// in the app), which keeps this logic testable without Supabase.
@MainActor
final class SetNewPasswordViewModel: ObservableObject {
    @Published var password = ""
    @Published var confirmation = ""
    @Published private(set) var passwordError: String?
    @Published private(set) var confirmationError: String?
    @Published private(set) var generalError: String?
    @Published private(set) var isWorking = false

    private let save: @MainActor (String) async throws -> Void

    init(save: @escaping @MainActor (String) async throws -> Void) {
        self.save = save
    }

    func submit() async {
        guard !isWorking else { return }
        let problems = PasswordRules.checkNewPassword(password, confirmation: confirmation)
        passwordError = problems.password
        confirmationError = problems.confirmation
        generalError = nil
        guard problems.isEmpty else { return }

        isWorking = true
        defer { isWorking = false }
        do {
            try await save(password)
        } catch let error as AppError {
            generalError = error.errorDescription
        } catch {
            generalError = Strings.Errors.generic
        }
    }
}
