import Foundation

/// Where a picked word came from. Only used to tell analytics how a check-in was made (typed,
/// browsed, from recents, or a mix); the word itself is never sent.
enum EmotionSource: Sendable {
    /// Tapped from the suggestions for what was typed.
    case typed
    /// Added by "Map my feelings".
    case mapped
    /// Picked from an energy zone.
    case browse
    /// Picked from the recent words.
    case recent

    var inputMethod: CheckInInputMethod {
        switch self {
        case .typed, .mapped: return .typed
        case .browse: return .browse
        case .recent: return .recent
        }
    }
}

/// A word the user picked for this check-in, with how strongly they feel it (1–5).
struct SelectedEmotion: Identifiable, Equatable, Sendable {
    let emotion: Emotion
    var intensity: Int
    var source: EmotionSource = .browse

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

    /// How the words were picked: the one source they share, or `mixed`.
    var inputMethod: CheckInInputMethod {
        let methods = Set(items.map(\.source.inputMethod))
        guard methods.count == 1, let only = methods.first else { return .mixed }
        return only
    }

    /// Whether "Map my feelings" added any of the words.
    var usedMapMyFeelings: Bool {
        items.contains { $0.source == .mapped }
    }

    /// Adds the word if it's new, removes it if it's already picked.
    mutating func toggle(_ emotion: Emotion, intensity: Int = defaultIntensity, source: EmotionSource = .browse) {
        if contains(emotion) {
            remove(emotion)
        } else {
            add(emotion, intensity: intensity, source: source)
        }
    }

    /// Adds the word at the end. Returns false, and keeps the intensity the user already chose,
    /// if the word is already picked.
    @discardableResult
    mutating func add(_ emotion: Emotion, intensity: Int = defaultIntensity, source: EmotionSource = .browse) -> Bool {
        guard !contains(emotion) else { return false }
        items.append(SelectedEmotion(emotion: emotion, intensity: Self.clamped(intensity), source: source))
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
