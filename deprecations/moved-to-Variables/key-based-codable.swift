import Foundation

public enum KeyFormattingStrategy: Sendable {
    case raw
    case uppercased
    case lowercased
    case capitalized
    case custom(@Sendable (String) -> String)

    @inline(__always)
    public func apply(_ s: String) -> String {
        switch self {
        case .raw:            return s
        case .uppercased:     return s.uppercased()
        case .lowercased:     return s.lowercased()
        case .capitalized:    return s.capitalized
        case .custom(let f):  return f(s)
        }
    }
}

public protocol KeyBasedCodable: Sendable, Codable, CaseIterable, RawRepresentable where RawValue == String {
    static var keyFormatting: KeyFormattingStrategy { get }
    var key: String { get }
}

extension KeyBasedCodable {
    // defaults to uppercased
    public static var keyFormatting: KeyFormattingStrategy { .uppercased }

    // defaults to formatting of choice to our rawValue
    public var key: String { Self.keyFormatting.apply(rawValue) }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.singleValueContainer()
        let key = try c.decode(String.self)
        if let m = Self.allCases.first(where: { $0.key == key || $0.rawValue == key }) {
            self = m
        } else {
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unknown key: \(key)")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(self.key)
    }
}
