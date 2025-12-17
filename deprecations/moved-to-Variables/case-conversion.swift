import Foundation

public enum CaseStyle: Sendable {
    case camel       // e.g. "myHTTPServer42"
    case snake       // e.g. "my_http_server_42"
    case pascal      // e.g. "MyHTTPServer42"
}

// Public separator policy (fast ASCII table, optional non-ASCII closure)
public struct SeparatorPolicy: Sendable {
    @usableFromInline var ascii: [Bool] = Array(repeating: false, count: 128)
    public var nonASCII: (@Sendable (UnicodeScalar) -> Bool)?

    @inlinable
    public init<S: Sequence>(
        scalars: S,
        nonASCII: (@Sendable (UnicodeScalar) -> Bool)? = nil
    ) where S.Element == UnicodeScalar {
        self.nonASCII = nonASCII
        for u in scalars { insert(u) }
    }

    // Convenience initializer for Character sequences (e.g., [" ", "_", "."])
    @inlinable
    public init<C: Sequence>(
        chars: C,
        nonASCII: (@Sendable (UnicodeScalar) -> Bool)? = nil
    ) where C.Element == Character {
        self.nonASCII = nonASCII
        for c in chars {
            for u in c.unicodeScalars { insert(u) }
        }
    }

    // Convenience: build from a simple ASCII string of separators (e.g., " _-./+:,")
    @inlinable
    public init(
        asciiString: String,
        nonASCII: (@Sendable (UnicodeScalar) -> Bool)? = nil
    ) {
        self.nonASCII = nonASCII
        for u in asciiString.unicodeScalars { insert(u) }
    }

    @inlinable
    public mutating func insert(_ u: UnicodeScalar) {
        if u.value < 128 { ascii[Int(u.value)] = true }
    }

    @inlinable
    public func contains(_ u: UnicodeScalar) -> Bool {
        if u.value < 128 { return ascii[Int(u.value)] }
        return nonASCII?(u) ?? false
    }

    /// Default (includes dot).
    public static let commonWithDot   = SeparatorPolicy(
        chars: [
            " ",
            "_",
            "-",
            ".",
            "/",
            "+",
            ":",
            ","
        ]
    )
    /// Variant that excludes dot (keeps file extensions intact).
    public static let commonNoDot     = SeparatorPolicy(
        chars: [
            " ",
            "_",
            "-",
            "/",
            "+",
            ":",
            ","
        ]
    )
    /// Whitespace only.
    public static let whitespaceOnly  = SeparatorPolicy(
        chars: [
            " "
        ]
    )
    
    // alternative ways to initialize: 

    // public static let commonWithDot = SeparatorPolicy(chars: Array(" _-./+:,"))
    // public static let commonNoDot = SeparatorPolicy(chars: Array(" _-/+:,"))
    // public static let whitespaceOnly = SeparatorPolicy(chars: Array(" "))

    // public static let commonWithDot   = SeparatorPolicy(asciiString: " _-./+:,")
    // public static let commonNoDot     = SeparatorPolicy(asciiString: " _-/+:,")
    // public static let whitespaceOnly  = SeparatorPolicy(asciiString: " ")


}

// Tokenizer (regex-free, ASCII-fast)
//
// Splits identifiers into "words" by:
// - underscores / hyphens (and any configured separators)
// - lower→Upper boundaries (e.g. "fooBar" → foo | Bar)
// - letter↔digit boundaries
// - acronym handling: "HTMLParser" → HTML | Parser, "URLToID" → URL | To | ID

@inline(__always)
private func isASCIIUpper(_ u: UnicodeScalar) -> Bool { u.value >= 65 && u.value <= 90 }   // A-Z
@inline(__always)
private func isASCIILower(_ u: UnicodeScalar) -> Bool { u.value >= 97 && u.value <= 122 }  // a-z
@inline(__always)
private func isASCIILetter(_ u: UnicodeScalar) -> Bool { isASCIIUpper(u) || isASCIILower(u) }
@inline(__always)
private func isASCIIDigit(_ u: UnicodeScalar) -> Bool { u.value >= 48 && u.value <= 57 }   // 0-9
@inline(__always)
private func isASCIIAlnum(_ u: UnicodeScalar) -> Bool { isASCIILetter(u) || isASCIIDigit(u) }

@inline(__always)
private func pascalizePreservingAfterPunct(_ s: String) -> String {
    guard !s.isEmpty else { return s }
    let scalars = Array(s.unicodeScalars)
    var out: [UnicodeScalar] = []
    out.reserveCapacity(scalars.count)

    // Uppercase first char (ASCII fast path), copy others with rule below.
    func upperASCII(_ u: UnicodeScalar) -> UnicodeScalar {
        if isASCIILower(u) { return UnicodeScalar(u.value - 32)! }
        return u
    }
    func lowerASCII(_ u: UnicodeScalar) -> UnicodeScalar {
        if isASCIIUpper(u) { return UnicodeScalar(u.value + 32)! }
        return u
    }

    // First scalar
    var prevWasPunct = false
    var prevRunLen = 0
    var curRunLen = 0

    let first = scalars[0]
    out.append(upperASCII(first))
    curRunLen = isASCIIAlnum(first) ? 1 : 0
    prevWasPunct = !isASCIIAlnum(first)

    // Rest
    for i in 1..<scalars.count {
        let u = scalars[i]
        if isASCIIAlnum(u) {
            if prevWasPunct {
                // Starting a new alnum run after punctuation.
                // If the *previous* run had length ≥ 2, we preserve the original case
                // (e.g., "My.File" keeps 'F'); otherwise we normalize to lower
                // (e.g., "A.B" → 'b').
                if prevRunLen >= 2 {
                    out.append(u)
                } else {
                    out.append(lowerASCII(u))
                }
                prevWasPunct = false
                curRunLen = 1
            } else {
                out.append(lowerASCII(u))
                curRunLen += 1
            }
        } else {
            out.append(u)
            prevWasPunct = true
            prevRunLen = curRunLen
            curRunLen = 0
        }
    }

    return String(String.UnicodeScalarView(out))
}

private enum CharKind { case upper, lower, digit, sep, other }

@inline(__always)
private func classify(_ u: UnicodeScalar, _ sep: SeparatorPolicy) -> CharKind {
    if sep.contains(u) { return .sep }
    if isASCIIUpper(u) { return .upper }
    if isASCIILower(u) { return .lower }
    if isASCIIDigit(u) { return .digit }
    return .other
}

private func tokenizeIdentifier(_ input: String, separators: SeparatorPolicy) -> [String] {
    if input.isEmpty { return [] }

    var tokens: [String] = []
    var current: [UnicodeScalar] = []

    let scalars = Array(input.unicodeScalars)
    let n = scalars.count

    @inline(__always)
    func flush() {
        if !current.isEmpty {
            tokens.append(String(String.UnicodeScalarView(current)))
            current.removeAll(keepingCapacity: true)
        }
    }

    for i in 0..<n {
        let u = scalars[i]
        let k = classify(u, separators)
        let prev = i > 0 ? scalars[i-1] : nil
        let next = i+1 < n ? scalars[i+1] : nil
        let pk = prev.map { classify($0, separators) }
        let nk = next.map { classify($0, separators) }

        switch k {
        case .sep:
            flush()

        case .other:
            current.append(u)

        case .digit:
            if let pk = pk, (pk == .upper || pk == .lower) {
                flush()
            }
            current.append(u)
            if let nk = nk, (nk == .upper || nk == .lower) {
                flush()
            }

        case .lower:
            if let pk = pk, pk == .upper, current.count >= 2 {
                // Only split if we truly had TWO consecutive uppers right before this lower,
                // e.g. "...HTMLP" + "arser" → split before 'P'.
                let beforeLast = current[current.count - 2]
                if isASCIIUpper(beforeLast) {
                    let last = current.removeLast()
                    flush()
                    current.append(last)
                }
            }
            current.append(u)

        case .upper:
            if let pk = pk {
                switch pk {
                case .lower, .digit, .sep:
                    // lower→Upper OR digit→Upper → boundary before this char
                    flush()
                    current.append(u)
                case .other:
                    // punctuation (not configured as separator) should NOT force a boundary
                    // keep accumulating into the same token (e.g., "My.File" stays one token)
                    current.append(u)
                case .upper:
                    // Upper followed by Upper:
                    // keep accumulating; we might split on next lower to handle acronyms
                    current.append(u)
                }
            } else {
                // start of string: include the first uppercase
                current.append(u)
            }
        }
    }
    flush()
    return tokens
}

// Formatters

@inline(__always)
private func lowerASCII(_ s: String) -> String { s.lowercased() }

@inline(__always)
private func upperFirstLowerRestASCII(_ s: String) -> String {
    guard let first = s.unicodeScalars.first else { return s }
    var out = String(UnicodeScalar(isASCIILower(first) ? first.value - 32 : first.value)!) // uppercased first (ASCII)
    if s.unicodeScalars.count > 1 {
        let rest = String(s.unicodeScalars.dropFirst())
        out += rest.lowercased()
    }
    return out
}

public func convertIdentifier(
    _ input: String,
    to style: CaseStyle,
    separators: SeparatorPolicy = .commonWithDot
) -> String {
    let parts = tokenizeIdentifier(input, separators: separators)
    if parts.isEmpty { return input }

    switch style {
    case .snake:
        return parts.map { lowerASCII($0) }.joined(separator: "_")

    case .camel:
        let head = lowerASCII(parts[0])
        if parts.count == 1 { return head }
        let tail = parts.dropFirst().map { upperFirstLowerRestASCII($0) }.joined()
        return head + tail

    case .pascal:
        return parts.map { pascalizePreservingAfterPunct($0) }.joined()
    }
}

// Back-compat functions (now forwarded to the core)

/// camelCase → snake_case
public func convertToSnakeCase(_ input: String) -> String {
    convertIdentifier(input, to: .snake)
}

/// snake_case → camelCase
public func convertToCamelCase(_ input: String) -> String {
    // We don't assume the source is snake; we just tokenize & rebuild camel.
    convertIdentifier(input, to: .camel)
}

/// anything → PascalCase
public func convertToPascalCase(_ input: String) -> String {
    convertIdentifier(input, to: .pascal)
}

// Overloads allowing explicit separator policy

public func convertToSnakeCase(_ input: String, separators: SeparatorPolicy) -> String {
    convertIdentifier(input, to: .snake, separators: separators)
}

public func convertToCamelCase(_ input: String, separators: SeparatorPolicy) -> String {
    convertIdentifier(input, to: .camel, separators: separators)
}

public func convertToPascalCase(_ input: String, separators: SeparatorPolicy) -> String {
    convertIdentifier(input, to: .pascal, separators: separators)
}

// Generic strategies for Encoders / Decoders

public enum KeyCaseMapping {
    /// Force all encoded keys to a style (your Swift properties can be any style).
    case encode(to: CaseStyle)
    /// On decode, transform incoming keys from their style to your property style.
    case decode(from: CaseStyle, to: CaseStyle = .camel)
}

public struct AnyKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) { self.stringValue = stringValue; self.intValue = nil }
    public init?(intValue: Int) { self.stringValue = "\(intValue)"; self.intValue = intValue }
}

extension JSONEncoder {
    /// Generic, style-driven encoder
    public static func encoder(keyCase: CaseStyle,
                               separators: SeparatorPolicy = .commonWithDot,
                               outputFormatting: JSONEncoder.OutputFormatting = .prettyPrinted) -> JSONEncoder {
        let enc = JSONEncoder()
        enc.outputFormatting = outputFormatting
        enc.keyEncodingStrategy = .custom { path in
            let k = path.last!.stringValue
            return AnyKey(stringValue: convertIdentifier(k, to: keyCase, separators: separators))!
        }
        return enc
    }

    // Back-compat factories
    public static func snakeCaseEncoder(separators: SeparatorPolicy = .commonWithDot) -> JSONEncoder {
        encoder(keyCase: .snake, separators: separators)
    }
    public static func camelCaseEncoder(separators: SeparatorPolicy = .commonWithDot) -> JSONEncoder {
        encoder(keyCase: .camel, separators: separators)
    }
    public static func pascalCaseEncoder(separators: SeparatorPolicy = .commonWithDot) -> JSONEncoder {
        encoder(keyCase: .pascal, separators: separators)
    }
}

extension JSONDecoder {
    /// Generic, style-driven decoder. `from` is the expected style in the JSON input.
    /// `to` is the style your Swift property names use (default: camel).
    public static func decoder(from: CaseStyle,
                               to: CaseStyle = .camel,
                               separators: SeparatorPolicy = .commonWithDot) -> JSONDecoder {
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .custom { path in
            let incoming = path.last!.stringValue
            let normalized = convertIdentifier(incoming, to: to, separators: separators)
            return AnyKey(stringValue: normalized)!
        }
        return dec
    }

    // Back-compat factories (assume structs use camelCase properties)
    public static func snakeCaseDecoder(separators: SeparatorPolicy = .commonWithDot) -> JSONDecoder {
        decoder(from: .snake, to: .camel, separators: separators)
    }
    public static func camelCaseDecoder(separators: SeparatorPolicy = .commonWithDot) -> JSONDecoder {
        decoder(from: .camel, to: .camel, separators: separators)
    }
    public static func pascalCaseDecoder(separators: SeparatorPolicy = .commonWithDot) -> JSONDecoder {
        decoder(from: .pascal, to: .camel, separators: separators)
    }
}

// Lightweight, modern CustomStrategies (generic), plus back-compat

public struct CustomStrategies {
    public static func encodeKeys(to style: CaseStyle,
                                  separators: SeparatorPolicy = .commonWithDot) -> JSONEncoder.KeyEncodingStrategy {
        .custom { keys in
            let last = keys.last!.stringValue
            return AnyKey(stringValue: convertIdentifier(last, to: style, separators: separators))!
        }
    }

    public static func decodeKeys(from _: CaseStyle,
                                  to target: CaseStyle = .camel,
                                  separators: SeparatorPolicy = .commonWithDot) -> JSONDecoder.KeyDecodingStrategy {
        .custom { keys in
            let last = keys.last!.stringValue
            return AnyKey(stringValue: convertIdentifier(last, to: target, separators: separators))!
        }
    }

    // Back-compat names
    public static func encodeCamelToSnake(separators: SeparatorPolicy = .commonWithDot) -> JSONEncoder.KeyEncodingStrategy {
        encodeKeys(to: .snake, separators: separators)
    }
    public static func encodeSnakeToCamel(separators: SeparatorPolicy = .commonWithDot) -> JSONEncoder.KeyEncodingStrategy {
        encodeKeys(to: .camel, separators: separators)
    }
    public static func decodeFromSnakeToCamel(separators: SeparatorPolicy = .commonWithDot) -> JSONDecoder.KeyDecodingStrategy {
        decodeKeys(from: .snake, to: .camel, separators: separators)
    }
    public static func decodeFromCamelToSnake(separators: SeparatorPolicy = .commonWithDot) -> JSONDecoder.KeyDecodingStrategy {
        decodeKeys(from: .camel, to: .snake, separators: separators)
    }
}

// Back-compat protocols (still work, now generalized under the hood)

public protocol CamelSnakeConvertible {
    func snake() -> String
    func camel() -> String
}

extension CamelSnakeConvertible where Self: RawRepresentable, Self.RawValue == String {
    public func snake() -> String { convertIdentifier(rawValue, to: .snake) }
    public func camel() -> String { convertIdentifier(rawValue, to: .camel) }
}

extension String {
    public func snake() -> String  { convertIdentifier(self, to: .snake) }
    public func camel() -> String  { convertIdentifier(self, to: .camel) }
    public func pascal() -> String { convertIdentifier(self, to: .pascal) }
}

// Quick Codable helpers (unchanged surface)

public protocol QuicklyEncodable: Encodable {}
public protocol QuicklyDecodable: Decodable {}

extension Data {
    public func toJSONString(encoding: String.Encoding = .utf8) -> String? {
        String(data: self, encoding: encoding)
    }
}

extension QuicklyEncodable {
    public func quickEncode(
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
