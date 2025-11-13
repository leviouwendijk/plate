import Foundation

public protocol LanguageSpecifying:
    RawRepresentable,
    CaseIterable,
    Codable,
    Sendable,
    Hashable
where RawValue == String {
    /// ex: "english"
    var long: String { get }

    /// ex: "en_US"
    func locale() throws -> [String]

    /// ex: "en"
    func short() throws -> String

    static var table: [Self: LanguageData] { get }

    func data() throws -> LanguageData

    /// canonical initializer from arbitrary user input
    init(from string: String) throws
}

extension LanguageSpecifying {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        try self.init(from: str)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.short())
    }
}

extension LanguageSpecifying {
    public func short() throws -> String {
        guard let entry = Self.table[self] else {
            throw LanguageSpecifierError.missingMapping(self)
        }
        return entry.abbreviation
    }

    public func locale() throws -> [String] {
        guard let entry = Self.table[self] else {
            throw LanguageSpecifierError.missingMapping(self)
        }
        return entry.locales
    }

    public func data() throws -> LanguageData {
        guard let entry = Self.table[self] else {
            throw LanguageSpecifierError.missingMapping(self)
        }
        return entry
    }

    // backwards compatiblity
    public var code: String {
        return  (try? short()) ?? ""
    }

    // backwards compatiblity
    public var name: String {
        return long
    }

    public var long: String {
        return self.rawValue
    }

    public init(from string: String) throws {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower   = trimmed.lowercased()
        let norm    = lower.replacingOccurrences(of: "-", with: "_")

        // 1. exact short match ("en", "nl")
        if let match = Self.allCases.first(where: { (try? $0.short()) == lower }) {
            self = match
            return
        }

        // 2. long match ("english", "dutch")
        if let match = Self.allCases.first(where: { $0.long.lowercased() == lower }) {
            self = match
            return
        }

        // 3. rawValue match (same as long, but direct enum case name)
        if let match = Self(rawValue: lower) {
            self = match
            return
        }

        // 4. locale match ("en_US", "nl-be", "NL_nl")
        if let match = Self.allCases.first(where: {
            guard let locales = try? $0.locale() else { return false }
            let normalizedLocales = locales.map {
                $0.lowercased().replacingOccurrences(of: "-", with: "_")
            }
            return normalizedLocales.contains(norm)
        }) {
            self = match
            return
        }

        throw LanguageSpecifierError.invalidCode(string)
    }
}
