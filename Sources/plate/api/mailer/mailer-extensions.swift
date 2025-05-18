import Foundation
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

public enum EmptyQueryBehavior {
    case none
    case all
}

extension Array where Element == CNContact {
    public func filteredClientContacts(
        matching query: String,
        uponEmptyReturn: EmptyQueryBehavior = .all
    ) -> [CNContact] {

        guard !query.isEmpty else {
            return (uponEmptyReturn == .all) ? self : []
        }
        
        let normalizedQuery = query.normalizedForClientDogSearch
        return self.filter {
            $0.givenName.normalizedForClientDogSearch.contains(normalizedQuery)
            || $0.familyName.normalizedForClientDogSearch.contains(normalizedQuery)
            || ((($0.emailAddresses.first?.value as String?)?
                    .normalizedForClientDogSearch.contains(normalizedQuery)) ?? false)
        }
    }
}
