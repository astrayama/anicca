// DELETE when the approved v2 library lands (every word then sets `zone:` explicitly).
//
// Rough zones for the v1 98-word library, so the new Log screens can be built and tried before
// the rewritten library is approved. Not tuned; don't ship it.

extension EmotionZone {
    private static let interimCharged: Set<String> = [
        "Anxious", "Restless", "Frustrated", "Overwhelmed", "Confused", "Scattered", "Hurt",
    ]

    private static let interimBright: Set<String> = [
        "Playful", "Passionate", "Joyful", "Creative", "Bold", "Radiant", "Empowered", "Blissful", "Expressive",
    ]

    static func interim(name: String, valence: EmotionValence) -> EmotionZone {
        if interimCharged.contains(name) { return .charged }
        if interimBright.contains(name) { return .bright }
        switch valence {
        case .negative: return .heavy
        case .positive: return .calm
        case .neutral: return .steady
        }
    }
}
