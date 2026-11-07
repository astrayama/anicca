import SwiftUI

/// The Log tab. Owns the check-in's navigation stack so a save can return to the start screen.
///
/// Start (type, recents, energy zones) → zone words → review → save.
struct LogView: View {
    @EnvironmentObject private var entitlements: EntitlementManager
    @StateObject private var viewModel = LogViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            CheckInStartView(viewModel: viewModel)
                .navigationDestination(for: LogRoute.self) { route in
                    switch route {
                    case .zone(let zone):
                        ZoneWordsView(zone: zone, viewModel: viewModel)
                    case .review:
                        CheckInReviewView(viewModel: viewModel)
                    }
                }
        }
        .overlay(alignment: .bottom) {
            if viewModel.showSavedToast {
                successToast
                    .padding(.bottom, AniccaTheme.Spacing.s32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(AniccaTheme.springAnimation, value: viewModel.showSavedToast)
        .onAppear {
            viewModel.refreshMonthCount()
            viewModel.refreshRecents()
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
        .alert("Something went wrong", isPresented: errorBinding) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private var successToast: some View {
        HStack(spacing: AniccaTheme.Spacing.s12) {
            if let center = viewModel.savedDominantCenter {
                Image(systemName: center.sfSymbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(center.inkColor)
            } else {
                Image(systemName: "sparkles")
                    .foregroundStyle(AniccaTheme.brandPrimary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.Log.savedToast).anicca(.headline)
                if entitlements.isPro {
                    Text("🔥 \(viewModel.savedStreak) day streak").anicca(.caption)
                }
            }
            Spacer()
        }
        .padding(AniccaTheme.Spacing.s16)
        .aniccaCard()
        .padding(.horizontal, AniccaTheme.Spacing.s20)
        .accessibilityElement(children: .combine)
    }
}
