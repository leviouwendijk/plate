import Foundation

public struct EnumParsingError: LocalizedError {
    public let enumName: String
    public let provided: String
    public let cases: String

    public var errorDescription: String? {
        """
        Failed to parse "\(provided)" to a valid case of enum '\(enumName)'

            Valid options are:
        \(cases.indent())
        """
    }
}

public protocol StringParsableEnum: RawRepresentable, CaseIterable where RawValue == String {
    static func available() -> String
    static func parse(from string: String) throws (EnumParsingError) -> Self
}

public extension StringParsableEnum {
    static func available() -> String {
        allCases.map { $0.rawValue }.joined(separator: "\n")
    }
    
    static func parse(from string: String) throws (EnumParsingError) -> Self {
        if let found = allCases.first(where: { $0.rawValue == string }) {
            return found
        }
        throw .init(
            enumName: String(describing: Self.self),
            provided: string,
            cases: available()
        )
    }
}

