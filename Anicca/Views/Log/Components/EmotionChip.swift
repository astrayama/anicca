import SwiftUI

/// One tappable feeling word. Shows its energy center as an icon (shape, not just colour), and a
/// checkmark when picked. Long-press shows what the word means.
struct EmotionChip: View {
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: emotion.center.sfSymbol)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(emotion.center.inkColor)
                    .accessibilityHidden(true)
                Text(emotion.name)
                    .font(.subheadline.weight(isSelected ? .semibold : .medium))
                    .foregroundStyle(AniccaTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(emotion.center.inkColor)
                        .transition(.scale.combined(with: .opacity))
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(minHeight: 44)
            .background {
                Capsule()
                    .fill(isSelected ? emotion.center.color.opacity(0.16) : Color.white.opacity(0.9))
            }
            .overlay {
                Capsule()
                    .strokeBorder(
                        isSelected ? emotion.center.inkColor : AniccaTheme.textMuted.opacity(0.35),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(AniccaTheme.springAnimation, value: isSelected)
        .sensoryFeedback(.selection, trigger: isSelected)
        .contextMenu {
            Button(isSelected ? Strings.Log.removeWord : Strings.Log.addWord, action: action)
        } preview: {
            EmotionDefinitionCard(emotion: emotion)
        }
        .accessibilityLabel(String(format: Strings.Log.wordA11yLabel, emotion.name, emotion.center.displayName))
        .accessibilityHint(emotion.definition)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// What a word means, its center and its zone. Shown on long-press.
struct EmotionDefinitionCard: View {
    let emotion: Emotion

    var body: some View {
        VStack(alignment: .leading, spacing: AniccaTheme.Spacing.s12) {
            Text(emotion.name)
                .font(.title2.weight(.bold))
                .foregroundStyle(AniccaTheme.textPrimary)
            Text(emotion.definition)
                .font(.body)
                .foregroundStyle(AniccaTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 6) {
                Label {
                    Text("\(emotion.center.displayName) · \(emotion.center.subtitle)")
                } icon: {
                    Image(systemName: emotion.center.sfSymbol).foregroundStyle(emotion.center.inkColor)
                }
                Label {
                    Text(emotion.zone.displayName)
                } icon: {
                    Image(systemName: emotion.zone.sfSymbol).foregroundStyle(emotion.zone.accent)
                }
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(AniccaTheme.textSecondary)
        }
        .padding(AniccaTheme.Spacing.s20)
        .frame(width: 300, alignment: .leading)
        .background(Color.white)
    }
}

/// Small inline label naming an energy center, used to group words inside a zone.
struct CenterTag: View {
    let center: EnergyCenter

    var body: some View {
        Label {
            Text(center.displayName)
        } icon: {
            Image(systemName: center.sfSymbol).foregroundStyle(center.inkColor)
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(AniccaTheme.textSecondary)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview("Chips") {
    VStack(alignment: .leading, spacing: 16) {
        CenterTag(center: .heart)
        FlowLayout {
            ForEach(Array(EmotionLibrary.heart.prefix(6).enumerated()), id: \.element.id) { index, emotion in
                EmotionChip(emotion: emotion, isSelected: index == 1) {}
            }
        }
        EmotionDefinitionCard(emotion: EmotionLibrary.root[0])
    }
    .padding()
    .background(AniccaTheme.background)
}
