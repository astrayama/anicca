import SwiftUI

/// Last step: how strong each picked feeling is (optional, starts at 3), an optional note, Save.
struct CheckInReviewView: View {
    @ObservedObject var viewModel: LogViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s20) {
                VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s4) {
                    Text(Strings.Log.reviewTitle)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(AniccaTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text(Strings.Log.reviewSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(AniccaTheme.textSecondary)
                }

                if viewModel.selection.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: AniccaTheme.Spacing.s12) {
                        ForEach(viewModel.selection.items) { item in
                            row(for: item)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }

                    Button {
                        dismiss()
                    } label: {
                        Label(Strings.Log.addMore, systemImage: "plus.circle")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AniccaTheme.brandPrimary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                }

                noteField

                Button {
                    isNoteFocused = false
                    Task { await viewModel.save() }
                } label: {
                    HStack(spacing: AniccaTheme.Spacing.s8) {
                        if viewModel.isSaving { ProgressView().tint(.white) }
                        Text(Strings.Log.saveCheckIn)
                    }
                }
                .buttonStyle(PrimaryButtonStyle(disabled: !viewModel.canSave))
                .disabled(!viewModel.canSave)
            }
            .padding(AniccaTheme.Spacing.s20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AniccaTheme.background.ignoresSafeArea())
        .animation(AniccaTheme.springAnimation, value: viewModel.selection.items.map(\.id))
        .navigationTitle(Strings.Log.reviewNavTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(Strings.Log.done) { isNoteFocused = false }
            }
        }
    }

    private func row(for item: SelectedEmotion) -> some View {
        let emotion = item.emotion
        return VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s8) {
            HStack(alignment: .top, spacing: AniccaTheme.Spacing.s12) {
                Image(systemName: emotion.center.sfSymbol)
                    .font(.headline)
                    .foregroundStyle(emotion.center.inkColor)
                    .padding(.top, 2)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(emotion.name)
                        .font(.headline)
                        .foregroundStyle(AniccaTheme.textPrimary)
                    Text("\(emotion.center.displayName) · \(emotion.zone.displayName)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AniccaTheme.textSecondary)
                }
                .accessibilityElement(children: .combine)
                Spacer(minLength: 0)
                Button {
                    viewModel.remove(emotion)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AniccaTheme.textMuted)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, -10)
                .padding(.trailing, -10)
                .accessibilityLabel(String(format: Strings.Log.removeA11y, emotion.name))
            }

            Text(emotion.definition)
                .font(.footnote)
                .foregroundStyle(AniccaTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            IntensityDots(
                value: Binding(
                    get: { viewModel.intensity(of: emotion) },
                    set: { viewModel.setIntensity($0, for: emotion) }
                ),
                tint: emotion.center.inkColor,
                label: emotion.name
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .aniccaCard(padding: AniccaTheme.Spacing.s16)
    }

    private var emptyState: some View {
        VStack(spacing: AniccaTheme.Spacing.s12) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(AniccaTheme.brandSecondary)
                .accessibilityHidden(true)
            Text(Strings.Log.reviewEmptyTitle)
                .font(.headline)
                .foregroundStyle(AniccaTheme.textPrimary)
            Button(Strings.Log.chooseFeelings) { dismiss() }
                .buttonStyle(SecondaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AniccaTheme.Spacing.s24)
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s8) {
            Text(Strings.Log.noteTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AniccaTheme.textPrimary)
            TextField(Strings.Log.notePlaceholder, text: $viewModel.note, axis: .vertical)
                .font(.body)
                .lineLimit(3...8)
                .focused($isNoteFocused)
                .padding(AniccaTheme.Spacing.s12)
                .background {
                    RoundedRectangle(cornerRadius: AniccaTheme.Radius.button, style: .continuous)
                        .fill(Color.white.opacity(0.9))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: AniccaTheme.Radius.button, style: .continuous)
                        .strokeBorder(AniccaTheme.textMuted.opacity(0.25), lineWidth: 1)
                }
        }
    }
}
