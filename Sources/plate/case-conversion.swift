import Foundation
// Camel and Snake conversion of parameter names

// Helper to convert camelCase to snake_case
public func convertToSnakeCase(_ input: String) -> String {
    let regex = try! NSRegularExpression(pattern: "([a-z0-9])([A-Z])")
    let range = NSRange(location: 0, length: input.utf16.count)
    let snakeCaseName = regex.stringByReplacingMatches(
        in: input,
        options: [],
        range: range,
        withTemplate: "$1_$2"
    ).lowercased()
    return snakeCaseName
}

// Helper to convert snake_case to camelCase
public func convertToCamelCase(_ input: String) -> String {
    let components = input.split(separator: "_")
    guard let first = components.first?.lowercased() else { return input }
    let camelCased = components.dropFirst().map { $0.capitalized }.joined()
    return first + camelCased
}

// Generalized protocol
public protocol CamelSnakeConvertible {
    func snake() -> String
    func camel() -> String
}

// Implementation for Enum type arguments
extension CamelSnakeConvertible where Self: RawRepresentable, Self.RawValue == String {
    public func snake() -> String {
        return convertToSnakeCase(rawValue)
    }

    public func camel() -> String {
        return convertToCamelCase(rawValue)
    }
}

// Implementation for String type arguments
extension String {
    public func snake() -> String {
        return convertToSnakeCase(self)
    }

    public func camel() -> String {
        return convertToCamelCase(self)
    }
}

// Implementation for CodingKey
extension CodingKey {
    public var snakeCase: String {
        return convertToSnakeCase(stringValue)
    }
    
    public var camelCase: String {
        return convertToCamelCase(stringValue)
    }
}

// For either case, but always with Encoder
extension JSONEncoder {
    public static func snakeCaseEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .custom { keys in
            let lastKey = keys.last!.stringValue
            return AnyKey(stringValue: convertToSnakeCase(lastKey))!
        }
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }

    public static func camelCaseEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .custom { keys in
            let lastKey = keys.last!.stringValue
            return AnyKey(stringValue: convertToCamelCase(lastKey))!
        }
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }
}

// For either case, but always with Decoder
extension JSONDecoder {
    public static func snakeCaseDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .custom { keys in
            let lastKey = keys.last!.stringValue
            return AnyKey(stringValue: convertToCamelCase(lastKey))!
        }
        return decoder
    }

    public static func camelCaseDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .custom { keys in
            let lastKey = keys.last!.stringValue
            return AnyKey(stringValue: convertToSnakeCase(lastKey))!
        }
        return decoder
    }
}

// Define a generic CodingKey that allows dynamic key conversion
public struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

public struct CustomStrategies {
    /// Encodes camelCase property names to snake_case keys in JSON
    public static func encodeCamelToSnake() -> JSONEncoder.KeyEncodingStrategy {
        return .custom { keys in
            let lastKey = keys.last!.stringValue
            return AnyKey(stringValue: convertToSnakeCase(lastKey))!
        }
    }
    
    /// Encodes snake_case property names to camelCase keys in JSON
    public static func encodeSnakeToCamel() -> JSONEncoder.KeyEncodingStrategy {
        return .custom { keys in
            let lastKey = keys.last!.stringValue
            return AnyKey(stringValue: convertToCamelCase(lastKey))!
        }
    }
    
    /// Decodes snake_case keys from JSON to camelCase property names in structs
    public static func decodeFromSnakeToCamel() -> JSONDecoder.KeyDecodingStrategy {
        return .custom { keys in
            let lastKey = keys.last!.stringValue
            return AnyKey(stringValue: convertToCamelCase(lastKey))!
        }
    }
    
    /// Decodes camelCase keys from JSON to snake_case property names in structs
    public static func decodeFromCamelToSnake() -> JSONDecoder.KeyDecodingStrategy {
        return .custom { keys in
            let lastKey = keys.last!.stringValue
            return AnyKey(stringValue: convertToSnakeCase(lastKey))!
        }
    }
}

public protocol QuicklyEncodable: Encodable {}
public protocol QuicklyDecodable: Decodable {}

extension Data {
    public func toJSONString(encoding: String.Encoding = .utf8) -> String? {
        return String(data: self, encoding: encoding)
    }
}

extension QuicklyEncodable {
    public public func quickEncode(
        encodingStrategy: JSONEncoder.KeyEncodingStrategy = CustomStrategies.encodeCamelToSnake(),
        outputFormatting: JSONEncoder.OutputFormatting = .prettyPrinted
    ) -> String? {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = encodingStrategy
            encoder.outputFormatting = outputFormatting
            let data = try encoder.encode(self)
            return data.toJSONString()
        } catch {
            print("Encoding failed with error: \(error)")
            return nil
        }
    }
}

extension QuicklyDecodable {
    public static func quickDecode(
        from jsonString: String,
        decodingStrategy: JSONDecoder.KeyDecodingStrategy = CustomStrategies.decodeFromSnakeToCamel()
    ) -> Self? {
        do {
            guard let data = jsonString.data(using: .utf8) else { return nil }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = decodingStrategy
            return try decoder.decode(Self.self, from: data)
        } catch {
            print("Decoding failed with error: \(error)")
            return nil
        }
    }
}
