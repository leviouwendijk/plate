import Foundation
import SwiftUI
import Contacts

extension String {
    public func htmlClean() -> String {
        return self
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\"", with: "\\\"")
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
    public func filteredClientContacts(uponEmptyReturn: EmptyQueryBehavior = .all) async throws -> [CNContact] {
        let allContacts = try await loadContacts()
        
        guard !self.isEmpty else {
            return (uponEmptyReturn == .all) ? allContacts : []
        }
        
        let normalizedQuery = self.normalizedForClientDogSearch
        return allContacts.filter {
            $0.givenName.normalizedForClientDogSearch.contains(normalizedQuery)
            || $0.familyName.normalizedForClientDogSearch.contains(normalizedQuery)
            || ((($0.emailAddresses.first?.value as String?)?
                    .normalizedForClientDogSearch.contains(normalizedQuery)) ?? false)
        }
    }
}

extension String {
    func levenshteinDistance(to target: String) -> Int {
        let s = Array(self)
        let t = Array(target)
        let m = s.count, n = t.count

        if m == 0 { return n }
        if n == 0 { return m }

        var dp = Array(
            repeating: Array(repeating: 0, count: n + 1),
            count: m + 1
        )

        for i in 0...m { dp[i][0] = i }
        for j in 0...n { dp[0][j] = j }

        for i in 1...m {
            for j in 1...n {
                if s[i - 1] == t[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = Swift.min(
                        dp[i - 1][j] + 1,      // deletion
                        dp[i][j - 1] + 1,      // insertion
                        dp[i - 1][j - 1] + 1    // substitution
                    )
                }
            }
        }
        return dp[m][n]
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

// extension Array where Element == CNContact {
//     public func filteredClientContacts(
//         matching query: String,
//         uponEmptyReturn: EmptyQueryBehavior = .all
//     ) -> [CNContact] {

//         guard !query.isEmpty else {
//             return (uponEmptyReturn == .all) ? self : []
//         }
        
//         let normalizedQuery = query.normalizedForClientDogSearch
//         return self.filter {
//             $0.givenName.normalizedForClientDogSearch.contains(normalizedQuery)
//             || $0.familyName.normalizedForClientDogSearch.contains(normalizedQuery)
//             || ((($0.emailAddresses.first?.value as String?)?
//                     .normalizedForClientDogSearch.contains(normalizedQuery)) ?? false)
//         }
//     }
// }

extension Array where Element == CNContact {
    public func filteredClientContacts(
        matching query: String,
        uponEmptyReturn: EmptyQueryBehavior = .all,
        fuzzyTolerance: Int = 1
    ) -> [CNContact] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return (uponEmptyReturn == .all) ? self : []
        }

        let tokens = trimmed.clientDogTokens

        return self.filter { contact in
            // build one searchable string
            let fullName = "\(contact.givenName) \(contact.familyName)"
                .normalizedForClientDogSearch
            let email = (contact.emailAddresses.first?.value as String? ?? "")
                .normalizedForClientDogSearch
            let haystack = (fullName + " " + email)
                .components(separatedBy: CharacterSet.whitespacesAndNewlines)

            // each token must either be a substring OR within fuzzyTolerance of some haystack word
            return tokens.allSatisfy { token in
                haystack.contains(where: { word in
                    if word.contains(token) { return true }
                    return word.levenshteinDistance(to: token) <= fuzzyTolerance
                })
            }
        }
    }
}

