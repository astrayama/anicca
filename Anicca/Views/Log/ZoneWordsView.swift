import SwiftUI

/// The words in one energy zone, grouped by energy center. Tap to pick; long-press for meaning.
struct ZoneWordsView: View {
    let zone: EmotionZone
    @ObservedObject var viewModel: LogViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s20) {
                header

                Text(Strings.Log.longPressHint)
                    .font(.footnote)
                    .foregroundStyle(AniccaTheme.textSecondary)

                ForEach(EmotionLibrary.groups(in: zone), id: \.center) { group in
                    VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s8) {
                        CenterTag(center: group.center)
                        FlowLayout {
                            ForEach(group.words) { emotion in
                                EmotionChip(emotion: emotion, isSelected: viewModel.isSelected(emotion)) {
                                    viewModel.toggle(emotion)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AniccaTheme.Spacing.s20)
            .padding(.top, AniccaTheme.Spacing.s8)
            .padding(.bottom, AniccaTheme.Spacing.s24)
        }
        .background(AniccaTheme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            if !viewModel.selection.isEmpty {
                SelectionTray(
                    items: viewModel.selection.items,
                    onRemove: { viewModel.remove($0) },
                    onNext: { viewModel.openReview() }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(AniccaTheme.springAnimation, value: viewModel.selection.isEmpty)
        .navigationTitle(zone.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: AniccaTheme.Spacing.s12) {
            Image(systemName: zone.sfSymbol)
                .font(.title2)
                .foregroundStyle(zone.accent)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(zone.displayName)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(AniccaTheme.textPrimary)
                Text(zone.energyDescription)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(zone.accent)
            }
            Spacer(minLength: 0)
        }
        .padding(AniccaTheme.Spacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay { RoundedRectangle(cornerRadius: 18, style: .continuous).fill(zone.tint.opacity(0.9)) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
