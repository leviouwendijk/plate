import Foundation

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
}
