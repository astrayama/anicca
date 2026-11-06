import Foundation

/// Builds the weekly reflection (Insights) and the daily practice suggestion (Home) from the
/// user's own check-ins using hand-written templates. Deterministic and on device: the same
/// data on the same day always gives the same text.
struct ReflectionService {
    private let insights = InsightsService()

    // MARK: - Weekly Reflection

    /// Reflection on the last 7 days, compared with the 7 days before. Nil when there are no
    /// entries in the last 7 days.
    func weeklyReflection(checkIns: [CheckIn], now: Date = Date()) -> WeeklyReflection? {
        let calendar = Calendar.current
        let weekCutoff = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let previousCutoff = calendar.date(byAdding: .day, value: -14, to: now) ?? now

        let thisWeek = checkIns.filter { $0.createdAt >= weekCutoff && $0.createdAt <= now }
        let lastWeek = checkIns.filter { $0.createdAt >= previousCutoff && $0.createdAt < weekCutoff }
        let entries = thisWeek.flatMap { $0.entries }
        guard let dominant = insights.dominantCenter(in: entries) else { return nil }

        var sentences: [String] = [rhythmSentence(thisWeek: thisWeek, lastWeek: lastWeek, calendar: calendar)]

        let topEmotions = insights.topEmotions(in: entries, limit: 3).map { $0.name.lowercased() }
        sentences.append(centerParagraph(for: dominant, topEmotions: Self.naturalList(topEmotions)))

        if let previous = insights.dominantCenter(in: lastWeek.flatMap { $0.entries }), previous != dominant {
            sentences.append("Last week your energy gathered in your \(previous.displayName) center; this week it moved to your \(dominant.displayName) center.")
        }

        if let tone = toneSentence(for: insights.valenceTrend(in: entries)) {
            sentences.append(tone)
        }

        let week = calendar.component(.weekOfYear, from: now)
        return WeeklyReflection(
            text: sentences.joined(separator: " "),
            dominantCenter: dominant,
            practices: Self.rotating(dominant.practices, seed: week, count: 3),
            weekStart: now.startOfWeek
        )
    }

    // MARK: - Daily Practices

    /// Three practices for `center`, rotating through its pool one step per calendar day.
    func dailyPractices(for center: EnergyCenter, on date: Date = Date(), count: Int = 3) -> [String] {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return Self.rotating(center.practices, seed: day, count: count)
    }

    // MARK: - Sentences

    private func rhythmSentence(thisWeek: [CheckIn], lastWeek: [CheckIn], calendar: Calendar) -> String {
        let count = thisWeek.count
        let days = Set(thisWeek.map { calendar.startOfDay(for: $0.createdAt) }).count

        var sentence = count == 1
            ? "You checked in once this week"
            : "You checked in \(count) times across \(days) \(days == 1 ? "day" : "days") this week"

        if !lastWeek.isEmpty {
            if count > lastWeek.count {
                sentence += ", up from \(lastWeek.count) the week before"
            } else if count < lastWeek.count {
                sentence += ", down from \(lastWeek.count) the week before"
            } else {
                sentence += ", the same as the week before"
            }
        }
        return sentence + "."
    }

    private func toneSentence(for valence: (positive: Int, neutral: Int, negative: Int)) -> String? {
        let total = valence.positive + valence.neutral + valence.negative
        guard total > 0 else { return nil }
        if Double(valence.negative) / Double(total) > 0.5 {
            return "Many of your entries carried a heavier tone. Noticing that is already a form of care, so go gently with yourself."
        }
        if Double(valence.positive) / Double(total) > 0.5 {
            return "Most of what you logged felt lighter and more open. It's worth noticing what supported that."
        }
        return "Your week held a mix of lighter and heavier moments, which is a normal part of being human."
    }

    private func centerParagraph(for center: EnergyCenter, topEmotions: String) -> String {
        switch center {
        case .root:
            return "Your focus settled in your Root center, reflecting themes of grounding, safety, and stability. With \(topEmotions) standing out, you may have been navigating uncertainty or looking for solid ground. Safety starts from within; small daily routines can help you feel more secure."
        case .sacral:
            return "Your emotional activity centered in your Sacral space, pointing to flow, creativity, and desire. Feelings of \(topEmotions) show you're in touch with your emotional waters. Letting yourself feel without judgment can free up creative and playful energy."
        case .solar:
            return "Your Solar Plexus took center stage, highlighting power, confidence, and personal agency. Feeling \(topEmotions) suggests you're working through your relationship with control, action, and self-worth. Build your inner fire steadily rather than all at once."
        case .heart:
            return "Your Heart center was the focal point, bringing up love, compassion, and emotional openness. Moving through \(topEmotions) points to your relationships, your boundaries, and how you accept yourself. Softening your edges and offering yourself compassion helps keep this center balanced."
        case .throat:
            return "Your Throat center was most active, reflecting truth, self-expression, and communication. With \(topEmotions) leading your entries, you may have felt a push to speak up, or struggled to find the words. Expression is also about listening closely to your own voice."
        case .thirdEye:
            return "Your Third Eye center was most active, highlighting intuition, perception, and inner clarity. Moving through \(topEmotions) suggests you're reflecting on your patterns and looking for what's true. Your gut feelings get clearer when you quiet the noise."
        case .crown:
            return "Your Crown center was most active, bringing forward connection, meaning, and your place in the bigger picture. Experiencing \(topEmotions) suggests a time of searching for purpose. You are part of something larger, even when it doesn't feel that way."
        }
    }

    // MARK: - Helpers

    /// `count` items from `pool`, starting at `seed` (wrapping), so the selection slides by one
    /// item each time the seed advances.
    static func rotating(_ pool: [String], seed: Int, count: Int) -> [String] {
        guard !pool.isEmpty else { return [] }
        let start = ((seed % pool.count) + pool.count) % pool.count
        return (0..<min(count, pool.count)).map { pool[(start + $0) % pool.count] }
    }

    /// "a", "a and b", "a, b and c".
    static func naturalList(_ items: [String]) -> String {
        switch items.count {
        case 0: return "your feelings"
        case 1: return items[0]
        default: return items.dropLast().joined(separator: ", ") + " and " + items[items.count - 1]
        }
    }
}
