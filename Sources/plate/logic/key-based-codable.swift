import Foundation

public protocol KeyBasedCodable: Codable, CaseIterable, RawRepresentable where RawValue == String {
    var key: String { get }
}

extension KeyBasedCodable {
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
