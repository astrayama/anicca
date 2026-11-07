import SwiftUI

enum EnergyCenter: String, CaseIterable, Codable, Identifiable {
    case root = "root"
    case sacral = "sacral"
    case solar = "solar"
    case heart = "heart"
    case throat = "throat"
    case thirdEye = "third_eye"
    case crown = "crown"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .root: return "Root"
        case .sacral: return "Sacral"
        case .solar: return "Solar Plexus"
        case .heart: return "Heart"
        case .throat: return "Throat"
        case .thirdEye: return "Third Eye"
        case .crown: return "Crown"
        }
    }

    var subtitle: String {
        switch self {
        case .root: return "Safety & Security"
        case .sacral: return "Creativity & Flow"
        case .solar: return "Power & Confidence"
        case .heart: return "Love & Compassion"
        case .throat: return "Expression & Truth"
        case .thirdEye: return "Insight & Intuition"
        case .crown: return "Connection & Meaning"
        }
    }

    var color: Color {
        switch self {
        case .root: return AniccaTheme.chakraRoot
        case .sacral: return AniccaTheme.chakraSacral
        case .solar: return AniccaTheme.chakraSolar
        case .heart: return AniccaTheme.chakraHeart
        case .throat: return AniccaTheme.chakraThroat
        case .thirdEye: return AniccaTheme.chakraThirdEye
        case .crown: return AniccaTheme.chakraCrown
        }
    }

    /// Darker version of `color` for icons and text on light backgrounds.
    var inkColor: Color {
        switch self {
        case .root: return AniccaTheme.chakraRootInk
        case .sacral: return AniccaTheme.chakraSacralInk
        case .solar: return AniccaTheme.chakraSolarInk
        case .heart: return AniccaTheme.chakraHeartInk
        case .throat: return AniccaTheme.chakraThroatInk
        case .thirdEye: return AniccaTheme.chakraThirdEyeInk
        case .crown: return AniccaTheme.chakraCrownInk
        }
    }

    var sfSymbol: String {
        switch self {
        case .root: return "shield.fill"
        case .sacral: return "drop.fill"
        case .solar: return "sun.max.fill"
        case .heart: return "heart.fill"
        case .throat: return "waveform"
        case .thirdEye: return "eye.fill"
        case .crown: return "sparkles"
        }
    }

    var number: Int {
        switch self {
        case .root: return 1
        case .sacral: return 2
        case .solar: return 3
        case .heart: return 4
        case .throat: return 5
        case .thirdEye: return 6
        case .crown: return 7
        }
    }

    var description: String {
        switch self {
        case .root:
            return "Your sense of safety, stability, and being at home in your body."
        case .sacral:
            return "Your capacity for creativity, play, and emotional flow."
        case .solar:
            return "Your confidence, agency, and ability to take action."
        case .heart:
            return "Your openness to love, both received and given."
        case .throat:
            return "Your ability to speak truthfully and express yourself."
        case .thirdEye:
            return "Your intuition, perception, and inner clarity."
        case .crown:
            return "Your connection to meaning, purpose, and wholeness."
        }
    }
 
    /// Hand-written practice pool (6 per center). `ReflectionService` rotates through it for the
    /// weekly reflection and Home's daily suggestion.
    var practices: [String] {
        switch self {
        case .root:
            return [
                "Stand barefoot on the earth or floor for 2 minutes, feeling your weight pull down.",
                "Take 5 slow, deep breaths, focusing entirely on the sensation of your feet on the ground.",
                "Wrap yourself in a heavy blanket and repeat quietly: 'I am safe and supported in this moment.'",
                "Name five things you can see, four you can hear, and three you can touch to bring yourself back to the room.",
                "Take a slow 5-minute walk outside, focusing on the physical connection of your feet to the earth.",
                "Spend a few minutes organizing one small area of your living space to create external stability."
            ]
        case .sacral:
            return [
                "Spend 3 minutes free-writing or doodling without any plan or goal.",
                "Drink a warm glass of water slowly, paying full attention to the sensation of the liquid.",
                "Stretch your hips gently while breathing slowly into your lower abdomen.",
                "Put on one song you love and let your body move however it wants until it ends.",
                "Take a slow shower or bath and notice the temperature and texture of the water on your skin.",
                "Dedicate 10 minutes to a creative hobby or play purely for the joy of it."
            ]
        case .solar:
            return [
                "Stand in a strong, open posture (shoulders back, hands on hips) for 1 minute.",
                "Name three small things you successfully accomplished or decided today.",
                "Take a brisk, fast-paced walk around the room to shift your physical energy.",
                "Pick one small task you've been putting off and finish it in the next 10 minutes.",
                "Say one clear 'yes' or 'no' today that matches what you actually want.",
                "Rub your palms together quickly for 20 seconds, then rest them on your stomach and breathe slowly."
            ]
        case .heart:
            return [
                "Place both hands over your chest, breathing softly under their warmth for 1 minute.",
                "Send a silent, genuine wish of wellness or peace to someone you care about.",
                "Write down one thing you truly appreciate about yourself right now.",
                "Send a short message to one person letting them know you're thinking of them.",
                "Speak to yourself the way you'd speak to a close friend who feels what you feel right now.",
                "Notice one small kindness today, given or received, and pause to take it in."
            ]
        case .throat:
            return [
                "Hum a soft, steady tone for 30 seconds to feel the vibration in your throat.",
                "Write down exactly what you are feeling in one unfiltered, raw sentence.",
                "Sip a cup of warm tea and practice letting your jaw completely relax.",
                "Say out loud, even if only to yourself, one thing you've been holding back.",
                "Sing along to one song, as loudly or softly as feels okay.",
                "In your next conversation, focus completely on hearing the other person rather than on your reply."
            ]
        case .thirdEye:
            return [
                "Close your eyes and breathe, visualizing a calm indigo light between your eyebrows.",
                "Look away from all screens and let your eyes rest on a single object in the room.",
                "Sit in complete silence for 2 minutes, simply observing thoughts passing like clouds.",
                "Before your next decision, pause, notice what your gut says first, and write it down.",
                "Take a 5-minute screen break and let your eyes rest on the farthest horizon you can see.",
                "Write down any repeating thoughts or intuitive nudges you've had recently."
            ]
        case .crown:
            return [
                "Look up at the sky or out a window, connecting with the vast space around you.",
                "Sit quietly and recall a moment you felt deeply connected to nature or a bigger purpose.",
                "Close your eyes and repeat: 'I am part of a larger, beautiful whole.'",
                "Spend 5 minutes outside, or with a plant, without your phone.",
                "Write down one thing that gave your life meaning this week, however small.",
                "Sit in silence for 3 minutes and simply let things be as they are."
            ]
        }
    }
}

enum CenterStatus: String, Codable {
    case noData
    case underactive
    case balanced
    case overactive

    var displayName: String {
        switch self {
        case .noData: return "No data"
        case .underactive: return "Underactive"
        case .balanced: return "Balanced"
        case .overactive: return "Overactive"
        }
    }

    var color: Color {
        switch self {
        case .noData: return AniccaTheme.textMuted
        case .underactive: return AniccaTheme.warning
        case .balanced: return AniccaTheme.success
        case .overactive: return AniccaTheme.brandSecondary
        }
    }
}
