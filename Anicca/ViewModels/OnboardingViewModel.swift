import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var step: Int = 0
    @Published var reminderTime: Date = OnboardingViewModel.defaultReminderTime()
    @Published var isWorking: Bool = false
    @Published var errorMessage: String?

    let totalSteps: Int = 4
    private var skippedIntro = false

    private static func defaultReminderTime() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 20
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }

    func next() {
        if step < totalSteps - 1 {
            withAnimation(AniccaTheme.springAnimation) { step += 1 }
        }
    }

    func back() {
        if step > 0 {
            withAnimation(AniccaTheme.springAnimation) { step -= 1 }
        }
    }

    var canSkip: Bool {
        step == 1 || step == 2
    }

    func skipToEnd() {
        skippedIntro = true
        withAnimation(AniccaTheme.springAnimation) { step = totalSteps - 1 }
    }

    func completeWithReminders() async {
        isWorking = true
        defer { isWorking = false }
        let granted = await NotificationService.shared.requestPermission()
        if granted {
            NotificationService.shared.scheduleDailyReminder(at: reminderTime)
            await AuthService.shared.updateReminderSettings(enabled: true, time: reminderTime)
            AnalyticsService.shared.track(.reminderEnabled(source: .onboarding))
        } else {
            await AuthService.shared.updateReminderSettings(enabled: false, time: nil)
            AnalyticsService.shared.track(.reminderPermissionDenied(source: .onboarding))
        }
        UserDefaults.standard.set(true, forKey: AppConfig.onboardingCompleteKey)
        AnalyticsService.shared.track(.onboardingCompleted(remindersEnabled: granted, skippedIntro: skippedIntro))
    }

    func completeWithoutReminders() async {
        UserDefaults.standard.set(true, forKey: AppConfig.onboardingCompleteKey)
        AnalyticsService.shared.track(.onboardingCompleted(remindersEnabled: false, skippedIntro: skippedIntro))
    }
}
