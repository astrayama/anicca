import Foundation
import SwiftData
import Supabase

@MainActor
final class CheckInService: ObservableObject {
    static let shared = CheckInService()

    private let client: SupabaseClient
    private var modelContext: ModelContext?

    private init() {
        self.client = SupabaseConfig.shared.client
    }

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        lowercaseLegacyUserIDsOnce(in: context)
    }

    /// Check-ins saved before user IDs were normalized can hold the UPPERCASE spelling, which the
    /// lowercase lookups no longer match. Repairs them once per install; the repair itself is
    /// idempotent, so the flag is only set after it has saved.
    private func lowercaseLegacyUserIDsOnce(in context: ModelContext) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: AppConfig.checkInUserIDsLowercasedKey) else { return }
        do {
            let changed = try LocalCheckInStore(context: context).lowercaseUserIDs()
            debugLog("🟢 CheckInService: lowercased the user ID on \(changed) local check-in(s).")
            defaults.set(true, forKey: AppConfig.checkInUserIDsLowercasedKey)
        } catch {
            debugLog("🔴 CheckInService: lowercasing local user IDs failed: \(error). Will retry next launch.")
        }
    }

    // MARK: - Save

    func saveCheckIn(
        userId: String,
        note: String?,
        entries: [(emotion: Emotion, intensity: Int)]
    ) async throws -> CheckIn {
        guard let context = modelContext else {
            throw AppError.unknown("Storage not ready.")
        }

        let checkIn = CheckIn(
            id: UUID(),
            userId: userId,
            createdAt: Date(),
            note: note?.isEmpty == true ? nil : note,
            entries: [],
            syncedToSupabase: false
        )

        for entry in entries {
            let item = EmotionEntry(
                id: UUID(),
                emotionName: entry.emotion.name,
                energyCenter: entry.emotion.center,
                intensity: max(1, min(5, entry.intensity)),
                checkInId: checkIn.id,
                checkIn: checkIn
            )
            checkIn.entries.append(item)
            context.insert(item)
        }

        context.insert(checkIn)
        try context.save()

        Task { [weak self] in
            await self?.syncCheckIn(checkIn)
        }

        return checkIn
    }

    // MARK: - Sync

    func syncCheckIn(_ checkIn: CheckIn) async {
        guard let context = modelContext else { return }
        guard let userUUID = UUID(uuidString: checkIn.userId) else { return }

        do {
            let checkInInsert = CheckInInsert(
                id: checkIn.id,
                user_id: userUUID,
                note: checkIn.note,
                created_at: checkIn.createdAt
            )
            try await client.from("check_ins").upsert(checkInInsert).execute()

            let entryInserts: [EmotionEntryInsert] = checkIn.entries.map { entry in
                EmotionEntryInsert(
                    id: entry.id,
                    check_in_id: checkIn.id,
                    user_id: userUUID,
                    emotion_name: entry.emotionName,
                    energy_center: entry.energyCenterRaw,
                    intensity: entry.intensity
                )
            }
            if !entryInserts.isEmpty {
                try await client.from("emotion_entries").upsert(entryInserts).execute()
            }
            checkIn.syncedToSupabase = true
            try? context.save()
        } catch {
            checkIn.syncedToSupabase = false
            try? context.save()
        }
    }

    func retryUnsyncedCheckIns() async {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { $0.syncedToSupabase == false }
        )
        guard let pending = try? context.fetch(descriptor) else { return }
        for checkIn in pending {
            await syncCheckIn(checkIn)
        }
    }

    // MARK: - Fetch

    func fetchLocalCheckIns(userId: String) -> [CheckIn] {
        guard let context = modelContext else { return [] }
        return LocalCheckInStore(context: context).checkIns(for: userId)
    }

    func loadRemoteCheckIns(userId: String) async {
        guard let context = modelContext, let userUUID = UUID(uuidString: userId) else { return }
        do {
            let remoteCheckIns: [CheckInDTO] = try await client
                .from("check_ins")
                .select()
                .eq("user_id", value: userUUID)
                .order("created_at", ascending: false)
                .execute()
                .value

            let remoteEntries: [EmotionEntryDTO] = try await client
                .from("emotion_entries")
                .select()
                .eq("user_id", value: userUUID)
                .execute()
                .value

            let entriesByCheckIn = Dictionary(grouping: remoteEntries, by: { $0.check_in_id })
            let local = fetchLocalCheckIns(userId: userId)
            let existingIDs = Set(local.map { $0.id })

            for dto in remoteCheckIns where !existingIDs.contains(dto.id) {
                let checkIn = CheckIn(
                    id: dto.id,
                    userId: userId,
                    createdAt: dto.created_at,
                    note: dto.note,
                    entries: [],
                    syncedToSupabase: true
                )
                context.insert(checkIn)
                for entryDTO in entriesByCheckIn[dto.id] ?? [] {
                    let center = EnergyCenter(rawValue: entryDTO.energy_center) ?? .heart
                    let entry = EmotionEntry(
                        id: entryDTO.id,
                        emotionName: entryDTO.emotion_name,
                        energyCenter: center,
                        intensity: entryDTO.intensity,
                        checkInId: dto.id,
                        checkIn: checkIn
                    )
                    checkIn.entries.append(entry)
                    context.insert(entry)
                }
            }
            try? context.save()
        } catch {
            // Silent — local data still works.
        }
    }

    // MARK: - Delete

    func deleteCheckIn(_ checkIn: CheckIn) async throws {
        guard let context = modelContext else { return }
        let id = checkIn.id
        context.delete(checkIn)
        try context.save()
        do {
            try await client.from("check_ins").delete().eq("id", value: id).execute()
        } catch {
            // Best effort — local delete is the source of truth for UI.
        }
    }

    // MARK: - Count

    func currentMonthCount(userId: String) -> Int {
        guard let context = modelContext else { return 0 }
        return LocalCheckInStore(context: context).monthCount(for: userId)
    }
}
