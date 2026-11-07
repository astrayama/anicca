import SwiftUI

/// Bottom bar listing the words picked so far, each removable, plus the Next button.
struct SelectionTray: View {
    let items: [SelectedEmotion]
    let onRemove: (Emotion) -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: AniccaTheme.Spacing.s12) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AniccaTheme.Spacing.s8) {
                        ForEach(items) { item in
                            Button {
                                onRemove(item.emotion)
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: item.emotion.center.sfSymbol)
                                        .foregroundStyle(item.emotion.center.inkColor)
                                    Text(item.emotion.name)
                                        .foregroundStyle(AniccaTheme.textPrimary)
                                    Image(systemName: "xmark")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(AniccaTheme.textSecondary)
                                }
                                .font(.footnote.weight(.semibold))
                                .padding(.horizontal, 12)
                                .frame(minHeight: 36)
                                .background(Capsule().fill(Color.white))
                                .overlay(Capsule().strokeBorder(item.emotion.center.inkColor.opacity(0.5), lineWidth: 1))
                                .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .id(item.id)
                            .accessibilityLabel(String(format: Strings.Log.removeA11y, item.emotion.name))
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, AniccaTheme.Spacing.s20)
                }
                .onChange(of: items.last?.id) { _, newest in
                    guard let newest else { return }
                    withAnimation(AniccaTheme.springAnimation) { proxy.scrollTo(newest, anchor: .trailing) }
                }
            }

            Button(action: onNext) {
                HStack(spacing: AniccaTheme.Spacing.s8) {
                    Text(Strings.Log.next)
                    Text("· \(items.count)")
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, AniccaTheme.Spacing.s20)
            .accessibilityLabel(String(format: Strings.Log.nextA11y, items.count))
        }
        .padding(.vertical, AniccaTheme.Spacing.s12)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        // The tray sits over the content; cap its text so it can't fill the screen.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .animation(AniccaTheme.springAnimation, value: items.map(\.id))
    }
}

#Preview {
    VStack {
        Spacer()
        SelectionTray(
            items: EmotionLibrary.all.prefix(4).map { SelectedEmotion(emotion: $0, intensity: 3) },
            onRemove: { _ in },
            onNext: {}
        )
    }
    .background(AniccaTheme.background)
}
