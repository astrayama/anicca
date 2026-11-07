import SwiftUI

/// Five tappable dots for how strong a feeling is (1–5). Filled vs outlined carries the value,
/// not colour alone, and a word ("Moderately") spells it out.
struct IntensityDots: View {
    @Binding var value: Int
    let tint: Color
    /// The feeling's name, for VoiceOver ("Anxious intensity").
    let label: String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(EmotionSelection.intensityRange, id: \.self) { level in
                Button {
                    value = level
                } label: {
                    Circle()
                        .fill(level <= value ? tint : Color.clear)
                        .overlay {
                            Circle().strokeBorder(level <= value ? tint : AniccaTheme.textMuted, lineWidth: 1.5)
                        }
                        .frame(width: 22, height: 22)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Text(Strings.Log.intensityLabel(value))
                .font(.footnote.weight(.medium))
                .foregroundStyle(AniccaTheme.textSecondary)
                .padding(.leading, AniccaTheme.Spacing.s4)
        }
        .animation(AniccaTheme.springAnimation, value: value)
        .sensoryFeedback(.impact(weight: .light), trigger: value)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: Strings.Log.intensityA11yLabel, label))
        .accessibilityValue(String(format: Strings.Log.intensityA11yValue, value, Strings.Log.intensityLabel(value)))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: value = min(value + 1, EmotionSelection.intensityRange.upperBound)
            case .decrement: value = max(value - 1, EmotionSelection.intensityRange.lowerBound)
            @unknown default: break
            }
        }
    }
}

private struct IntensityDotsPreview: View {
    @State private var value = 3

    var body: some View {
        IntensityDots(value: $value, tint: EnergyCenter.heart.inkColor, label: "Sad")
            .padding()
    }
}

#Preview {
    IntensityDotsPreview()
}
