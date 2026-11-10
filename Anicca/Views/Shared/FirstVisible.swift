import SwiftUI

extension View {
    /// Runs `action` the first time at least half of this view is inside the enclosing scroll view,
    /// once per appearance. For views far down a scroll view, where `onAppear` fires too early.
    func onFirstVisible(perform action: @escaping () -> Void) -> some View {
        modifier(FirstVisibleModifier(action: action))
    }
}

private struct FirstVisibleModifier: ViewModifier {
    let action: () -> Void
    @State private var didFire = false

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: Bool.self) { proxy in
                guard let viewport = proxy.bounds(of: .scrollView) else { return false }
                let own = CGRect(origin: .zero, size: proxy.size)
                let visible = own.intersection(viewport)
                return !visible.isNull && own.height > 0 && visible.height >= own.height / 2
            } action: { isVisible in
                guard isVisible, !didFire else { return }
                didFire = true
                action()
            }
            .onDisappear { didFire = false }
    }
}
