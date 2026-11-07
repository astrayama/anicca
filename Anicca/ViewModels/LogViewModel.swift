import Foundation
import SwiftUI
import SwiftData
import Combine

// MARK: - Navigation

/// Screens pushed on top of the check-in start screen.
enum LogRoute: Hashable {
    case zone(EmotionZone)
    case review
}

/// What happened the last time the user tapped "Map my feelings".
enum MapFeedback: Equatable {
    case added([String])
    case alreadySelected
    case noMatch
}

/// Drives the whole check-in: start screen (type, recents, zones) → zone words → review → save.
///
/// Navigating never changes the check-in in progress. Only Clear and a successful Save do.
@MainActor
final class LogViewModel: ObservableObject {

    // MARK: - Check-in in progress

    @Published var path: [LogRoute] = []
    @Published var query: String = "" {
        didSet { if query != oldValue { mapFeedback = nil } }
    }
    @Published private(set) var selection = EmotionSelection()
    @Published var note: String = ""
    @Published private(set) var recents: [Emotion] = []
    @Published var mapFeedback: MapFeedback?

    // MARK: - Save, paywall and toast

    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var showPaywall: Bool = false
    @Published var showSavedToast: Bool = false
    @Published var savedStreak: Int = 0
    @Published var savedDominantCenter: EnergyCenter?
    @Published var monthCount: Int = 0

    private let checkInService = CheckInService.shared
    private let insightsService = InsightsService()
    private let auth = AuthService.shared
    private let entitlements = EntitlementManager.shared
    private var entitlementChange: AnyCancellable?

    init() {
        // Re-render when the plan changes, so the limit warning clears the moment someone upgrades.
        entitlementChange = entitlements.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
    }

    // MARK: - Computed

    var queryMode: LogQueryMode { LogQueryMode.mode(for: query) }

    /// Library words for what's typed: live search for a word or two, the on-device matcher's
    /// reading for a sentence.
    var suggestions: [Emotion] {
        switch queryMode {
        case .idle: return []
        case .words: return Array(EmotionMatcher.search(query).prefix(12))
        case .sentence: return EmotionMatcher.match(query).map(\.emotion)
        }
    }

    var canSave: Bool { !selection.isEmpty && !isSaving }

    /// True when there's something Clear would throw away.
    var hasDraft: Bool {
        !selection.isEmpty
            || !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var freeLimitWarning: String? {
        guard let remaining = entitlements.planTier.checkInsLeftWarning(checkInsThisMonth: monthCount)
        else { return nil }
        return String(format: Strings.Log.freeLimitWarning, remaining)
    }

    var nextCheckInNumber: Int {
        (auth.currentUser?.totalCheckIns ?? 0) + 1
    }

    // MARK: - Picking words

    func isSelected(_ emotion: Emotion) -> Bool {
        selection.contains(emotion)
    }

    func toggle(_ emotion: Emotion) {
        selection.toggle(emotion)
    }

    /// Tapping a word suggested from typed text keeps the strength the wording implied
    /// ("really anxious" → 4).
    func toggleSuggestion(_ emotion: Emotion) {
        if selection.contains(emotion) {
            selection.remove(emotion)
            return
        }
        let guess = EmotionMatcher.match(query).first { $0.emotion == emotion }?.intensity
        selection.add(emotion, intensity: guess ?? EmotionSelection.defaultIntensity)
    }

    func remove(_ emotion: Emotion) {
        selection.remove(emotion)
    }

    func intensity(of emotion: Emotion) -> Int {
        selection.intensity(of: emotion) ?? EmotionSelection.defaultIntensity
    }

    func setIntensity(_ value: Int, for emotion: Emotion) {
        selection.setIntensity(value, for: emotion)
    }

    /// Reads the typed sentence on device and adds every feeling it finds, with the strength its
    /// wording implies. Never changes a strength the user already set.
    func mapQuery() {
        let mapped = EmotionMatcher.match(query)
        guard !mapped.isEmpty else {
            mapFeedback = .noMatch
            return
        }
        let added = mapped.filter { selection.add($0.emotion, intensity: $0.intensity) }.map(\.emotion.name)
        mapFeedback = added.isEmpty ? .alreadySelected : .added(added)
    }

    // MARK: - Navigation

    func openZone(_ zone: EmotionZone) {
        path.append(.zone(zone))
    }

    func openReview() {
        guard !selection.isEmpty, path.last != .review else { return }
        path.append(.review)
    }

    /// Throws away the check-in in progress but stays where the user is.
    func clearAll() {
        selection.removeAll()
        query = ""
        note = ""
        mapFeedback = nil
    }

    /// Clears everything and goes back to the start screen.
    func reset() {
        clearAll()
        path = []
    }

    // MARK: - Data

    func refreshMonthCount() {
        guard let userId = auth.currentUser?.id else { return }
        monthCount = checkInService.currentMonthCount(userId: userId)
    }

    /// The user's most recent words, newest check-in first, mapped back to library words by name
    /// and center. Words no longer in the library are skipped. Nothing new is stored.
    func refreshRecents(limit: Int = 8) {
        guard let userId = auth.currentUser?.id else {
            recents = []
            return
        }
        var seen = Set<String>()
        var result: [Emotion] = []
        outer: for checkIn in checkInService.fetchLocalCheckIns(userId: userId).prefix(30) {
            // SwiftData doesn't keep relationship order; strongest first reads best.
            let entries = checkIn.entries.sorted {
                $0.intensity != $1.intensity ? $0.intensity > $1.intensity : $0.emotionName < $1.emotionName
            }
            for entry in entries {
                guard let emotion = EmotionLibrary.emotion(named: entry.emotionName, in: entry.energyCenter),
                      seen.insert(emotion.id).inserted else { continue }
                result.append(emotion)
                if result.count == limit { break outer }
            }
        }
        recents = result
    }

    // MARK: - Save

    func save() async {
        guard let user = auth.currentUser else {
            errorMessage = Strings.Errors.generic
            return
        }
        refreshMonthCount()
        if entitlements.planTier.hasReachedMonthlyLimit(checkInsThisMonth: monthCount) {
            showPaywall = true
            return
        }
        guard canSave else { return }
        isSaving = true
        defer { isSaving = false }

        do {
            let saved = try await checkInService.saveCheckIn(
                userId: user.id,
                note: note,
                entries: selection.entries
            )
            savedDominantCenter = insightsService.dominantCenter(in: saved.entries)

            let allCheckIns = checkInService.fetchLocalCheckIns(userId: user.id)
            let streak = insightsService.streak(from: allCheckIns)
            await auth.updateStreakStats(
                streak: streak,
                totalCheckIns: allCheckIns.count,
                lastDate: saved.createdAt
            )
            savedStreak = streak
            refreshMonthCount()
            reset()
            refreshRecents()
            showToast()
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = Strings.Errors.generic
        }
    }

    private func showToast() {
        withAnimation(AniccaTheme.springAnimation) { showSavedToast = true }
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation(AniccaTheme.springAnimation) { self?.showSavedToast = false }
        }
    }
}
