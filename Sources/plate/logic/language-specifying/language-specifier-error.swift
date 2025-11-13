import Foundation

public enum LanguageSpecifierError: Error, LocalizedError, Sendable {
    case invalidCode(String)
    case missingMapping(any LanguageSpecifying)

    public var errorDescription: String? {
        switch self {
        case .invalidCode(let input):
            return "Invalid language: '\(input)'"
        case .missingMapping(let lang):
            return "Missing language mapping for '\(lang.rawValue)'."
        }
    }
}
