import SwiftUI

/// The five areas of the energy × pleasantness map (Russell's circumplex, in plain words).
///
/// Users pick a zone first, then a word inside it. Energy centers stay the data model: every
/// word still belongs to exactly one center, and only name + center are saved.
enum EmotionZone: String, CaseIterable, Identifiable, Sendable {
    // Reading order on the grid: top row, middle band, bottom row.
    case charged
    case bright
    case steady
    case heavy
    case calm

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .charged: return Strings.Zones.chargedName
        case .bright: return Strings.Zones.brightName
        case .steady: return Strings.Zones.steadyName
        case .heavy: return Strings.Zones.heavyName
        case .calm: return Strings.Zones.calmName
        }
    }

    /// The two plain questions behind the zone: how much energy, and how it feels.
    var energyDescription: String {
        switch self {
        case .charged: return Strings.Zones.chargedDescription
        case .bright: return Strings.Zones.brightDescription
        case .steady: return Strings.Zones.steadyDescription
        case .heavy: return Strings.Zones.heavyDescription
        case .calm: return Strings.Zones.calmDescription
        }
    }

    /// A few typical words, shown on the tile so it's recognised rather than decoded.
    var examples: String {
        switch self {
        case .charged: return Strings.Zones.chargedExamples
        case .bright: return Strings.Zones.brightExamples
        case .steady: return Strings.Zones.steadyExamples
        case .heavy: return Strings.Zones.heavyExamples
        case .calm: return Strings.Zones.calmExamples
        }
    }

    var sfSymbol: String {
        switch self {
        case .charged: return "bolt.fill"
        case .bright: return "sunrise.fill"
        case .steady: return "circle.lefthalf.filled"
        case .heavy: return "cloud.fill"
        case .calm: return "leaf.fill"
        }
    }

    /// Soft background for the zone's tile and header.
    var tint: Color {
        switch self {
        case .charged: return AniccaTheme.zoneChargedTint
        case .bright: return AniccaTheme.zoneBrightTint
        case .steady: return AniccaTheme.zoneSteadyTint
        case .heavy: return AniccaTheme.zoneHeavyTint
        case .calm: return AniccaTheme.zoneCalmTint
        }
    }

    /// Icon and border colour. Text on tiles always uses `AniccaTheme.textPrimary`.
    var accent: Color {
        switch self {
        case .charged: return AniccaTheme.zoneChargedAccent
        case .bright: return AniccaTheme.zoneBrightAccent
        case .steady: return AniccaTheme.zoneSteadyAccent
        case .heavy: return AniccaTheme.zoneHeavyAccent
        case .calm: return AniccaTheme.zoneCalmAccent
        }
    }

    /// Valences a word may have and still live in this zone.
    var allowedValences: Set<EmotionValence> {
        switch self {
        case .charged, .heavy: return [.negative]
        case .bright, .calm: return [.positive]
        case .steady: return [.positive, .neutral, .negative]
        }
    }

    var accessibilityHint: String {
        String(format: Strings.Zones.accessibilityHint, energyDescription, examples)
    }
}
