import SwiftUI

/// Shown over everything once a password-reset link signs the user in (see
/// `AuthService.passwordResetEmail`). Saving the new password finishes signing in; Cancel signs the
/// reset session out and goes back to the sign-in screen.
struct SetNewPasswordView: View {
    @EnvironmentObject private var auth: AuthService
    @StateObject private var viewModel = SetNewPasswordViewModel { password in
        try await AuthService.shared.setNewPassword(password)
    }
    @FocusState private var focusedField: Field?

    private enum Field {
        case password, confirmation
    }

    var body: some View {
        ZStack {
            MeshGradientBackground()
            ScrollView {
                VStack(spacing: AniccaTheme.Spacing.s24) {
                    headerBlock
                    formCard
                    if let error = viewModel.generalError {
                        Text(error)
                            .anicca(.caption)
                            .foregroundStyle(AniccaTheme.error)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(AniccaTheme.Spacing.s20)
                .padding(.top, AniccaTheme.Spacing.s32)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear { focusedField = .password }
    }

    private var headerBlock: some View {
        VStack(spacing: AniccaTheme.Spacing.s8) {
            Image(systemName: "key.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(AniccaTheme.brandPrimary)
            Text(Strings.Auth.newPasswordTitle)
                .anicca(.title)
                .multilineTextAlignment(.center)
            Text(Strings.Auth.newPasswordSubtitle)
                .anicca(.subheadline)
                .multilineTextAlignment(.center)
            if let email = auth.passwordResetEmail, !email.isEmpty {
                Text(email)
                    .anicca(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, AniccaTheme.Spacing.s8)
    }

    private var formCard: some View {
        VStack(spacing: AniccaTheme.Spacing.s16) {
            passwordField(
                title: Strings.Auth.newPassword,
                text: $viewModel.password,
                error: viewModel.passwordError,
                focus: .password
            )
            .submitLabel(.next)
            .onSubmit { focusedField = .confirmation }

            passwordField(
                title: Strings.Auth.confirmNewPassword,
                text: $viewModel.confirmation,
                error: viewModel.confirmationError,
                focus: .confirmation
            )
            .submitLabel(.done)
            .onSubmit { save() }

            Button(action: save) {
                HStack {
                    if viewModel.isWorking {
                        ProgressView().tint(.white)
                    }
                    Text(Strings.Auth.saveNewPassword)
                }
            }
            .buttonStyle(PrimaryButtonStyle(disabled: viewModel.isWorking))
            .disabled(viewModel.isWorking)
            .accessibilityLabel(Strings.Auth.saveNewPassword)

            Button(Strings.Auth.cancelNewPassword) {
                Task { await auth.cancelPasswordReset() }
            }
            .buttonStyle(GhostButtonStyle())
            .disabled(viewModel.isWorking)
        }
        .aniccaCard()
    }

    private func save() {
        focusedField = nil
        Task { await viewModel.submit() }
    }

    private func passwordField(
        title: String,
        text: Binding<String>,
        error: String?,
        focus: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s4) {
            Text(title)
                .anicca(.subheadline)
            SecureField(title, text: text)
                .focused($focusedField, equals: focus)
                .textContentType(.newPassword)
                .padding(AniccaTheme.Spacing.s12)
                .background {
                    RoundedRectangle(cornerRadius: AniccaTheme.Radius.button, style: .continuous)
                        .fill(Color.white.opacity(0.7))
                        .overlay {
                            RoundedRectangle(cornerRadius: AniccaTheme.Radius.button, style: .continuous)
                                .stroke(error == nil ? AniccaTheme.textMuted.opacity(0.25) : AniccaTheme.error, lineWidth: 1)
                        }
                }
            if let error {
                Text(error)
                    .anicca(.caption)
                    .foregroundStyle(AniccaTheme.error)
            }
        }
    }
}
