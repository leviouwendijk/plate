import Foundation

public enum LanguageSpecifierError: Error, LocalizedError, Sendable {
    case invalidCode(String)
    public var errorDescription: String? {
        switch self {
        case .invalidCode(let input):
            return "Invalid language: '\(input)'"
        }
    }
}

public enum LanguageSpecifier: String, RawRepresentable, Sendable, CaseIterable {
    case english
    case dutch

    public var code: String {
        switch self {
        case .english: return "en"
        case .dutch:   return "nl"
        }
    }

    public var name: String {
        return self.rawValue
    }

    public init(from string: String) throws {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()

        if let match = LanguageSpecifier.allCases.first(where: { $0.code == lower }) {
            self = match
            return
        }

        if let match = LanguageSpecifier.allCases.first(where: { $0.name.lowercased() == lower }) {
            self = match
            return
        }
        throw LanguageSpecifierError.invalidCode(string)
    }
}

extension LanguageSpecifier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        try self.init(from: str)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.code)
    }
}
