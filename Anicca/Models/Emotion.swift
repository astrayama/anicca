import Foundation

enum EmotionValence: String, Hashable, Sendable {
    case positive
    case neutral
    case negative
}

/// One word in the emotion library.
///
/// Check-ins store only `name` and `center` (see `EmotionEntry`), so a shipped word's name and
/// center are effectively permanent. If a word is renamed or removed, old entries keep resolving
/// through `EmotionLibrary.valence(forStoredName:center:)`.
struct Emotion: Identifiable, Hashable, Sendable {
    let name: String
    let center: EnergyCenter
    /// Where the word sits on the energy × pleasantness map. Drives the Log tab's zone grid.
    let zone: EmotionZone
    let valence: EmotionValence
    /// Plain one-line meaning, shown when the user long-presses a word.
    let definition: String
    /// Other words people use for this feeling. Used by search and the free-text matcher.
    let synonyms: [String]

    /// Stable across launches and installs, e.g. "root::Anxious". Never persisted.
    var id: String { "\(center.rawValue)::\(name)" }

    var sfSymbol: String { center.sfSymbol }

    init(
        name: String,
        center: EnergyCenter,
        zone: EmotionZone? = nil,
        valence: EmotionValence,
        definition: String,
        synonyms: [String] = []
    ) {
        self.name = name
        self.center = center
        self.zone = zone ?? EmotionZone.interim(name: name, valence: valence)
        self.valence = valence
        self.definition = definition
        self.synonyms = synonyms
    }

    static func == (lhs: Emotion, rhs: Emotion) -> Bool { lhs.id == rhs.id }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
