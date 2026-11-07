import SwiftUI

/// The five energy zones laid out like the circumplex: high energy on top, low energy at the
/// bottom, unpleasant on the left, pleasant on the right, and "Steady or mixed" across the middle.
/// At accessibility text sizes it becomes a single column in the same reading order.
struct ZoneGrid: View {
    let selectedCount: (EmotionZone) -> Int
    let onSelect: (EmotionZone) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: AniccaTheme.Spacing.s12) {
                ForEach(EmotionZone.allCases) { tile($0, isWide: true) }
            }
        } else {
            Grid(horizontalSpacing: AniccaTheme.Spacing.s12, verticalSpacing: AniccaTheme.Spacing.s12) {
                GridRow {
                    tile(.charged, isWide: false)
                    tile(.bright, isWide: false)
                }
                GridRow {
                    tile(.steady, isWide: true)
                        .gridCellColumns(2)
                }
                GridRow {
                    tile(.heavy, isWide: false)
                    tile(.calm, isWide: false)
                }
            }
        }
    }

    private func tile(_ zone: EmotionZone, isWide: Bool) -> some View {
        ZoneTile(zone: zone, selectedCount: selectedCount(zone), isWide: isWide) {
            onSelect(zone)
        }
    }
}

struct ZoneTile: View {
    let zone: EmotionZone
    let selectedCount: Int
    let isWide: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Image(systemName: zone.sfSymbol)
                        .font(.title3)
                        .foregroundStyle(zone.accent)
                    Spacer(minLength: AniccaTheme.Spacing.s4)
                    if selectedCount > 0 {
                        Text(String(format: Strings.Log.zoneSelectedCount, selectedCount))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(zone.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.white))
                    }
                }
                Text(zone.displayName)
                    .font(.headline)
                    .foregroundStyle(AniccaTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(zone.energyDescription)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(zone.accent)
                    .fixedSize(horizontal: false, vertical: true)
                Text(zone.examples)
                    .font(.caption)
                    .foregroundStyle(AniccaTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: isWide ? 0 : 128, alignment: .topLeading)
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous).fill(zone.tint.opacity(0.9))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(zone.accent.opacity(selectedCount > 0 ? 0.7 : 0.25), lineWidth: selectedCount > 0 ? 1.5 : 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(PressableStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(zone.displayName)
        .accessibilityHint(zone.accessibilityHint)
        .accessibilityValue(selectedCount > 0 ? String(format: Strings.Log.zoneSelectedCount, selectedCount) : "")
        .accessibilityAddTraits(.isButton)
    }
}

/// Slight press-down feedback for large tappable cards.
struct PressableStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ScrollView {
        ZoneGrid(selectedCount: { $0 == .heavy ? 2 : 0 }, onSelect: { _ in })
            .padding()
    }
    .background(AniccaTheme.background)
}
