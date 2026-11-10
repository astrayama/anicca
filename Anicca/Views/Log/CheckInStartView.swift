import SwiftUI

/// The one start screen for a check-in. Three ways in, all on the same screen:
/// type a word or a sentence, tap a recent word, or choose an energy zone.
struct CheckInStartView: View {
    @ObservedObject var viewModel: LogViewModel
    @FocusState private var isFieldFocused: Bool
    @State private var isConfirmingClear = false

    private var trimmedQuery: String {
        viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s24) {
                header
                queryField

                if viewModel.queryMode != .idle {
                    suggestionsSection
                } else if !viewModel.recents.isEmpty {
                    recentSection
                }

                zonesSection
            }
            .padding(.horizontal, AniccaTheme.Spacing.s20)
            .padding(.top, AniccaTheme.Spacing.s8)
            .padding(.bottom, AniccaTheme.Spacing.s24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background { MeshGradientBackground() }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.selection.isEmpty {
                SelectionTray(
                    items: viewModel.selection.items,
                    onRemove: { viewModel.remove($0) },
                    onNext: {
                        isFieldFocused = false
                        viewModel.openReview()
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(AniccaTheme.springAnimation, value: viewModel.selection.isEmpty)
        .animation(AniccaTheme.springAnimation, value: viewModel.queryMode)
        .navigationTitle(String(format: Strings.Log.checkInNumber, viewModel.nextCheckInNumber))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.hasDraft {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Strings.Log.clear) {
                        if viewModel.selection.isEmpty {
                            withAnimation(AniccaTheme.springAnimation) { viewModel.clearAll() }
                        } else {
                            isConfirmingClear = true
                        }
                    }
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(Strings.Log.done) { isFieldFocused = false }
            }
        }
        .confirmationDialog(Strings.Log.clearConfirmTitle, isPresented: $isConfirmingClear, titleVisibility: .visible) {
            Button(String(format: Strings.Log.clearConfirmAction, viewModel.selection.count), role: .destructive) {
                withAnimation(AniccaTheme.springAnimation) { viewModel.clearAll() }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s4) {
            Text(Strings.Log.title)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(AniccaTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let warning = viewModel.freeLimitWarning {
                Text(warning)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(AniccaTheme.textSecondary)
            }
        }
    }

    // MARK: - Text field

    private var queryField: some View {
        HStack(alignment: .top, spacing: AniccaTheme.Spacing.s8) {
            TextField(Strings.Log.fieldPlaceholder, text: $viewModel.query, axis: .vertical)
                .font(.body)
                .lineLimit(1...4)
                .focused($isFieldFocused)
                .submitLabel(.done)
                .autocorrectionDisabled(false)
            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AniccaTheme.textMuted)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear text")
            }
        }
        .padding(.horizontal, AniccaTheme.Spacing.s16)
        .padding(.vertical, AniccaTheme.Spacing.s12)
        .background {
            RoundedRectangle(cornerRadius: AniccaTheme.Radius.button, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .shadow(color: AniccaTheme.cardShadowColor, radius: 8, y: 3)
        }
        .overlay {
            RoundedRectangle(cornerRadius: AniccaTheme.Radius.button, style: .continuous)
                .strokeBorder(isFieldFocused ? AniccaTheme.brandPrimary.opacity(0.5) : AniccaTheme.textMuted.opacity(0.25), lineWidth: 1)
        }
        // A vertical TextField inserts a newline on Return instead of submitting.
        .onChange(of: viewModel.query) { _, newValue in
            guard newValue.contains("\n") else { return }
            viewModel.query = newValue
                .replacingOccurrences(of: "\n", with: " ")
                .trimmingCharacters(in: .whitespaces)
            if viewModel.queryMode == .sentence {
                viewModel.mapQuery()
            }
            isFieldFocused = false
        }
    }

    // MARK: - Suggestions from typed text

    @ViewBuilder
    private var suggestionsSection: some View {
        let suggestions = viewModel.suggestions
        VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s12) {
            if suggestions.isEmpty {
                if viewModel.queryMode == .words {
                    noMatchCard
                } else {
                    feedbackLine(Strings.Log.mapNoMatch, systemImage: "questionmark.circle")
                }
            } else {
                sectionLabel(viewModel.queryMode == .words ? Strings.Log.matches : Strings.Log.fromWhatYouWrote)
                FlowLayout {
                    ForEach(suggestions) { emotion in
                        EmotionChip(emotion: emotion, isSelected: viewModel.isSelected(emotion)) {
                            viewModel.toggleSuggestion(emotion)
                        }
                    }
                }
                if viewModel.queryMode == .sentence {
                    mapControls
                }
            }
        }
    }

    private var mapControls: some View {
        VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s8) {
            Button {
                isFieldFocused = false
                withAnimation(AniccaTheme.springAnimation) { viewModel.mapQuery() }
            } label: {
                Label(Strings.Log.mapButton, systemImage: "sparkles")
            }
            .buttonStyle(SecondaryButtonStyle())

            if let feedback = viewModel.mapFeedback {
                switch feedback {
                case .added(let names):
                    feedbackLine(String(format: Strings.Log.mapAdded, ListFormatter.localizedString(byJoining: names)),
                                 systemImage: "checkmark.circle.fill")
                case .alreadySelected:
                    feedbackLine(Strings.Log.mapAlreadySelected, systemImage: "checkmark.circle")
                case .noMatch:
                    feedbackLine(Strings.Log.mapNoMatch, systemImage: "questionmark.circle")
                }
            } else {
                Text(Strings.Log.mapHint)
                    .font(.footnote)
                    .foregroundStyle(AniccaTheme.textSecondary)
            }
        }
    }

    private var noMatchCard: some View {
        VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s4) {
            Text(String(format: Strings.Log.noMatchTitle, trimmedQuery))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AniccaTheme.textPrimary)
            Text(Strings.Log.noMatchBody)
                .font(.footnote)
                .foregroundStyle(AniccaTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AniccaTheme.Spacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: AniccaTheme.Radius.button, style: .continuous)
                .fill(Color.white.opacity(0.8))
        }
        .accessibilityElement(children: .combine)
    }

    private func feedbackLine(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.footnote.weight(.medium))
            .foregroundStyle(AniccaTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Recent words

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s12) {
            sectionLabel(Strings.Log.recent)
            FlowLayout {
                ForEach(viewModel.recents) { emotion in
                    EmotionChip(emotion: emotion, isSelected: viewModel.isSelected(emotion)) {
                        viewModel.toggle(emotion, source: .recent)
                    }
                }
            }
        }
    }

    // MARK: - Energy zones

    private var zonesSection: some View {
        VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s12) {
            sectionLabel(Strings.Log.chooseByEnergy)
            ZoneGrid(
                selectedCount: { viewModel.selection.count(in: $0) },
                onSelect: { zone in
                    isFieldFocused = false
                    viewModel.openZone(zone)
                }
            )
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(AniccaTheme.textSecondary)
            .accessibilityAddTraits(.isHeader)
    }
}
