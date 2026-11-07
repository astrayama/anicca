import Foundation

extension EmotionLibrary {
    static let wordsPerCenter = 10
    static let wordsPerZone = 12...16
    static let minimumZonesPerCenter = 3
    static let maximumDefinitionLength = 90

    /// Every rule the library must keep (see `docs/emotion-library-v2.md`). Returns one message per
    /// broken rule; empty means the library is fine. `all` asserts on this in debug builds, and the
    /// unit tests check it too, so an edit that breaks a rule fails fast.
    static func integrityProblems(in words: [Emotion]) -> [String] {
        var problems: [String] = []
        let names = Set(words.map { $0.name.lowercased() })

        for center in EnergyCenter.allCases {
            let inCenter = words.filter { $0.center == center }
            if inCenter.count != wordsPerCenter {
                problems.append("\(center.displayName) has \(inCenter.count) words, expected \(wordsPerCenter)")
            }
            let zones = Set(inCenter.map(\.zone))
            if zones.count < minimumZonesPerCenter {
                problems.append("\(center.displayName) spans \(zones.count) zones, expected at least \(minimumZonesPerCenter)")
            }
        }

        if names.count != words.count {
            problems.append("Word names are not unique")
        }

        var synonymOwner: [String: String] = [:]
        for word in words {
            if !word.zone.allowedValences.contains(word.valence) {
                problems.append("\(word.name) is \(word.valence) but sits in \(word.zone.rawValue)")
            }
            if word.definition.isEmpty || word.definition.count > maximumDefinitionLength {
                problems.append("\(word.name) needs a definition of 1–\(maximumDefinitionLength) characters")
            }
            for synonym in word.synonyms.map({ $0.lowercased() }) {
                if names.contains(synonym) {
                    problems.append("Synonym \"\(synonym)\" of \(word.name) is also a word name")
                }
                if let owner = synonymOwner[synonym], owner != word.name {
                    problems.append("Synonym \"\(synonym)\" belongs to both \(owner) and \(word.name)")
                }
                synonymOwner[synonym] = word.name
            }
        }

        for zone in EmotionZone.allCases {
            let inZone = words.filter { $0.zone == zone }
            if !wordsPerZone.contains(inZone.count) {
                problems.append("\(zone.rawValue) has \(inZone.count) words, expected \(wordsPerZone)")
            }
            // The zone tile's example words must be real words in that zone.
            let zoneNames = Set(inZone.map { $0.name.lowercased() })
            for example in zone.examples.split(separator: ",") {
                let name = example.trimmingCharacters(in: .whitespaces).lowercased()
                if !zoneNames.contains(name) {
                    problems.append("Zone example \"\(name)\" is not a \(zone.rawValue) word")
                }
            }
        }
        return problems
    }
}
