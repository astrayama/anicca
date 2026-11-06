import Foundation

/// The Pro weekly reflection on the Insights tab, assembled on device by `ReflectionService`
/// from the user's own check-ins.
struct WeeklyReflection: Identifiable {
    let id = UUID()
    let text: String
    let dominantCenter: EnergyCenter
    let practices: [String]
    let weekStart: Date
}
