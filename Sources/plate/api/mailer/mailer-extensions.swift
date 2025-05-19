import Foundation
import SwiftUI
import Contacts

extension String {
    public func htmlClean() -> String {
        return self
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    public func viewableEndpointString() -> String {
        return "/\(self)"
        .replacingOccurrences(of: "/", with: " / ")
    }
}

extension String {
    public var replacePipesWithWhitespace: String {
        return self.replacingOccurrences(of: "|", with: " ")
    }

    public var normalizedForClientDogSearch: String {
        return self
        .folding(options: .diacriticInsensitive, locale: .current)
        .replacePipesWithWhitespace
        .components(separatedBy: CharacterSet.whitespacesAndNewlines)
        .filter { !$0.isEmpty }
        .joined(separator: " ")
        .lowercased()
    }

    public func extractClientDog() throws -> MailerAPIClientVariable {
        try splitClientDog(from: self)
    }

    public var commaSeparatedValuesToParsableArgument: String {
        self
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: " ")
    }

    public var commaSeparatedValuesToList: [String] {
        self
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
    }

    public func containsRawTemplateVariables(ignoring exceptions: [String] = []) -> Bool {
        let negativeLookahead = exceptions
            .map { "(?!\($0)\\b)" }
            .joined()
        
        let pattern = #"\{\{\s*\#(negativeLookahead)[^}]+\s*\}\}"#
        
        return self.range(of: pattern, options: .regularExpression) != nil
    }

    @MainActor
    public func filteredClientContacts(
        uponEmptyReturn: EmptyQueryBehavior = .all,
        fuzzyTolerance: Int = 2
    ) async throws -> [CNContact] {
        let allContacts = try await loadContacts()

        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return (uponEmptyReturn == .all) ? allContacts : []
        }

        let tokens = trimmed
            .normalizedForClientDogSearch
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        return allContacts.filter { contact in
            let haystack = contact.searchableWords()

            return tokens.allSatisfy { token in
                haystack.contains(where: { word in
                    if word.contains(token) { return true }
                    return word.levenshteinDistance(to: token) <= fuzzyTolerance
                })
            }
        }
    }
}

extension String {
    public var asciiSearchNormalized: String {
        var s = self
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripCombiningMarks, reverse: false)
            ?? self

        let ligatures: [String: String] = [
            "ß": "ss", "Æ": "AE", "æ": "ae",
            "Œ": "OE", "œ": "oe"
        ]

        for (special, plain) in ligatures {
            s = s.replacingOccurrences(of: special, with: plain)
        }

        let dashChars = CharacterSet(charactersIn: "–—−-") // en, em, minus, non-break
        s = s.components(separatedBy: dashChars).joined(separator: "-")

        let punct = CharacterSet.punctuationCharacters
        s = s.components(separatedBy: punct).joined(separator: " ")

        let comps = s
            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return comps.joined(separator: " ").lowercased()
    }
}


extension String {
    func levenshteinDistance(to target: String) -> Int {
        let s = Array(self)
        let t = Array(target)
        let m = s.count, n = t.count

        if m == 0 { return n }
        if n == 0 { return m }

        // self[0..<i-1] and target[0..<j]
        var prev = Array(0...n)
        var curr = [Int](repeating: 0, count: n + 1)

        for i in 1...m {
            curr[0] = i
            for j in 1...n {
                let cost = (s[i-1] == t[j-1]) ? 0 : 1
                // deletion:   prev[j] + 1
                // insertion:  curr[j-1] + 1
                // substitution: prev[j-1] + cost
                curr[j] = Swift.min(
                    prev[j]     + 1,
                    curr[j-1]   + 1,
                    prev[j-1]   + cost
                )
            }
            // roll the rows
            (prev, curr) = (curr, prev)
        }
        return prev[n]
    }

    public var clientDogTokens: [String] {
        normalizedForClientDogSearch
            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .filter { !$0.isEmpty }
    }

    public func highlighted(
        _ tokens: [String], 
        highlightColor: Color = .accentColor
        // baseFont: Font = .body
    ) -> AttributedString {
        var attr = AttributedString(self)
        let lower = self.lowercased()
        for token in tokens {
            var start = lower.startIndex
            while let range = lower[start...].range(of: token) {
                let nsRange = NSRange(range, in: self)
                if let swiftRange = Range(nsRange, in: attr) {
                    attr[swiftRange].foregroundColor = highlightColor
                    // attr[swiftRange].font = .bold()
                }
                start = range.upperBound
            }
        }
        return attr
    }
}


public enum EmptyQueryBehavior {
    case none
    case all
}

extension Array where Element == CNContact {
    public func filteredClientContacts(
        matching query: String,
        uponEmptyReturn: EmptyQueryBehavior = .all,
        fuzzyTolerance: Int = 2,
        sortByProximity: Bool = true
    ) -> [CNContact] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return (uponEmptyReturn == .all) ? self : []
        }

        let tokens = trimmed.clientDogTokens

        let filtered = self.filter { contact in
            let haystack = contact.searchableWords()

            // each token must either be a substring OR within fuzzyTolerance of some haystack word
            return tokens.allSatisfy { token in
                haystack.contains(where: { word in
                    if word.contains(token) { return true }
                    return word.levenshteinDistance(to: token) <= fuzzyTolerance
                })
            }
        }

        guard sortByProximity else { return filtered }
        return filtered.sorted {
            $0.matchScore(tokens: tokens) < $1.matchScore(tokens: tokens)
        }
    }
}

extension CNContact {
    public func searchableWords() -> [String] {
        let fullName = "\(givenName) \(familyName)"
        .normalizedForClientDogSearch

        let email = (emailAddresses.first?.value as String? ?? "")
        .normalizedForClientDogSearch

        return (fullName + " " + email)
        .components(separatedBy: CharacterSet.whitespacesAndNewlines)
        .filter { !$0.isEmpty }
    }

    public func matchScore(tokens: [String]) -> Int {
        let haystack = self.searchableWords()

        return tokens.reduce(0) { sum, token in
            let best = haystack.map { word in
                word.contains(token)
                  ? 0
                  : word.levenshteinDistance(to: token)
            }.min() ?? Int.max
            return sum + best
        }
    }
}
