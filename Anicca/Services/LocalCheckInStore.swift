import Foundation
import SwiftData

/// The on-device side of check-ins: reads keyed by user, and the repair for rows saved before user
/// IDs were lowercased. It has no Supabase dependency, so unit tests run it on an in-memory store.
@MainActor
struct LocalCheckInStore {
    let context: ModelContext

    /// Newest first. Either spelling of the user ID finds the same check-ins.
    func checkIns(for userId: String) -> [CheckIn] {
        let userId = UserID.normalized(userId)
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func monthCount(for userId: String, now: Date = Date(), calendar: Calendar = .current) -> Int {
        guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start else { return 0 }
        return checkIns(for: userId).filter { $0.createdAt >= monthStart }.count
    }

    /// Lowercases user IDs saved in the old UPPERCASE form and returns how many rows changed.
    /// Running it again changes nothing.
    @discardableResult
    func lowercaseUserIDs() throws -> Int {
        var changed = 0
        for checkIn in try context.fetch(FetchDescriptor<CheckIn>()) {
            let normalized = UserID.normalized(checkIn.userId)
            if checkIn.userId != normalized {
                checkIn.userId = normalized
                changed += 1
            }
        }
        if changed > 0 { try context.save() }
        return changed
    }
}
