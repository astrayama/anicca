import Foundation

/// A word the user picked for this check-in, with how strongly they feel it (1–5).
struct SelectedEmotion: Identifiable, Equatable, Sendable {
    let emotion: Emotion
    var intensity: Int

    var id: String { emotion.id }
}

/// The words picked for the check-in in progress, in the order they were picked.
struct EmotionSelection: Equatable, Sendable {
    static let defaultIntensity = 3
    static let intensityRange = 1...5

    private(set) var items: [SelectedEmotion] = []

    var isEmpty: Bool { items.isEmpty }
    var count: Int { items.count }

    func contains(_ emotion: Emotion) -> Bool {
        items.contains { $0.emotion == emotion }
    }

    func intensity(of emotion: Emotion) -> Int? {
        items.first { $0.emotion == emotion }?.intensity
    }

    func count(in zone: EmotionZone) -> Int {
        items.filter { $0.emotion.zone == zone }.count
    }

    /// Adds the word if it's new, removes it if it's already picked.
    mutating func toggle(_ emotion: Emotion, intensity: Int = defaultIntensity) {
        if contains(emotion) {
            remove(emotion)
        } else {
            add(emotion, intensity: intensity)
        }
    }

    /// Adds the word at the end. Returns false, and keeps the intensity the user already chose,
    /// if the word is already picked.
    @discardableResult
    mutating func add(_ emotion: Emotion, intensity: Int = defaultIntensity) -> Bool {
        guard !contains(emotion) else { return false }
        items.append(SelectedEmotion(emotion: emotion, intensity: Self.clamped(intensity)))
        return true
    }

    mutating func remove(_ emotion: Emotion) {
        items.removeAll { $0.emotion == emotion }
    }

    mutating func setIntensity(_ value: Int, for emotion: Emotion) {
        guard let index = items.firstIndex(where: { $0.emotion == emotion }) else { return }
        items[index].intensity = Self.clamped(value)
    }

    mutating func removeAll() {
        items.removeAll()
    }

    /// The shape `CheckInService.saveCheckIn` expects.
    var entries: [(emotion: Emotion, intensity: Int)] {
        items.map { ($0.emotion, $0.intensity) }
    }

    private static func clamped(_ value: Int) -> Int {
        min(max(value, intensityRange.lowerBound), intensityRange.upperBound)
    }
}

/// What the start screen does with the text the user has typed.
enum LogQueryMode: Equatable, Sendable {
    /// Nothing typed: show recents and the zone grid.
    case idle
    /// One or two words: show matching library words as you type.
    case words
    /// A sentence: offer "Map my feelings", which reads the whole thing on device.
    case sentence

    static let sentenceWordThreshold = 3

    static func mode(for text: String) -> LogQueryMode {
        let wordCount = text.split { $0.isWhitespace || $0.isNewline }.count
        switch wordCount {
        case 0: return .idle
        case ..<sentenceWordThreshold: return .words
        default: return .sentence
        }
    }
}
