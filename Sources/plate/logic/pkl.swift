import Foundation

public enum PklParserError: Error, CustomStringConvertible {
    case ioError(String)
    case syntaxError(String)
    case missingField(String)
    case invalidValue(field: String, value: String)

    public var description: String {
        switch self {
        case .ioError(let msg):              return "I/O Error: \(msg)"
        case .syntaxError(let msg):          return "Syntax Error: \(msg)"
        case .missingField(let f):           return "Missing required field: \(f)"
        case .invalidValue(let f, let v):    return "Invalid value '\(v)' for field '\(f)'"
        }
    }
}

public class PklParser {
    private let input: String
    private var idx: String.Index

    public init(_ text: String) {
        self.input = text
        self.idx = text.startIndex
    }

    public func parseBuildObject() throws -> BuildObjectConfiguration {
        var uuid: UUID?
        var name: String?
        var type: ExecutableObjectType?
        var version: ObjectVersion?
        var details: String?
        var author: String?
        var update: String?

        while skipWhitespaceAndNewlines() {
            let key = try parseIdentifier()
            skipWhitespaceAndNewlines()
            if key == "version" {
                if idx < input.endIndex && input[idx] == "=" {
                    idx = input.index(after: idx)
                    skipWhitespaceAndNewlines()
                }
                let dict = try parseBlock()
                guard
                  let maj = dict["major"] as? Int,
                  let min = dict["minor"] as? Int,
                  let pat = dict["patch"] as? Int
                else {
                    throw PklParserError.syntaxError("version block missing major/minor/patch")
                }
                version = ObjectVersion(major: maj, minor: min, patch: pat)
            } else {
                try expect("=")
                let val = try parseValue()
                switch key {
                case "uuid":
                    guard let s = val as? String, let u = UUID(uuidString: s) else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    uuid = u
                case "name":
                    guard let s = val as? String else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    name = s
                case "type":
                    guard let s = val as? String, let t = ExecutableObjectType(rawValue: s) else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    type = t
                case "details":
                    guard let s = val as? String else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    details = s
                case "author":
                    guard let a = val as? String else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    author = a
                case "update":
                    guard let u = val as? String else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    update = u
                default:
                    break
                }
            }
        }

        guard let uu = uuid else     { throw PklParserError.missingField("uuid") }
        guard let nm = name else     { throw PklParserError.missingField("name") }
        guard let tp = type else     { throw PklParserError.missingField("type") }
        guard let ver = version else { throw PklParserError.missingField("version") }
        guard let det = details else { throw PklParserError.missingField("details") }
        guard let au = author else     { throw PklParserError.missingField("author") }
        guard let up = update else     { throw PklParserError.missingField("update") }

        return BuildObjectConfiguration(
            uuid: uu, 
            name: nm, 
            type: tp,
            version: ver, 
            details: det,
            author: au,
            update: up
        )
    }

    @discardableResult
    private func skipWhitespaceAndNewlines() -> Bool {
        _ = idx
        while idx < input.endIndex && input[idx].isWhitespaceOrNewline {
            idx = input.index(after: idx)
        }
        return idx < input.endIndex
    }

    private func parseIdentifier() throws -> String {
        skipWhitespaceAndNewlines()
        let start = idx
        while idx < input.endIndex, input[idx].isLetter {
            idx = input.index(after: idx)
        }
        guard start < idx else {
            throw PklParserError.syntaxError("Expected identifier at position \(position)")
        }
        return String(input[start..<idx])
    }

    private func expect(_ char: Character) throws {
        skipWhitespaceAndNewlines()
        guard idx < input.endIndex && input[idx] == char else {
            throw PklParserError.syntaxError("Expected '\(char)' at \(position)")
        }
        idx = input.index(after: idx)
    }

    private func parseValue() throws -> Any {
        skipWhitespaceAndNewlines()
        guard idx < input.endIndex else {
            throw PklParserError.syntaxError("Unexpected EOF when parsing value")
        }
        let c = input[idx]
        if c == "\"" {
            return try parseString()
        } else if c.isNumber {
            return try parseNumber()
        } else {
            throw PklParserError.syntaxError("Unexpected value start '\(c)' at \(position)")
        }
    }

    private func parseString() throws -> String {
        idx = input.index(after: idx)
        let start = idx
        while idx < input.endIndex && input[idx] != "\"" {
            idx = input.index(after: idx)
        }
        guard idx < input.endIndex else {
            throw PklParserError.syntaxError("Unterminated string literal")
        }
        let s = String(input[start..<idx])
        idx = input.index(after: idx) // skip closing quote
        return s
    }

    private func parseNumber() throws -> Int {
        let start = idx
        while idx < input.endIndex && input[idx].isNumber {
            idx = input.index(after: idx)
        }
        let numStr = String(input[start..<idx])
        guard let n = Int(numStr) else {
            throw PklParserError.syntaxError("Invalid integer '\(numStr)'")
        }
        return n
    }

    private func parseBlock() throws -> [String: Any] {
        try expect("{")
        var dict = [String: Any]()
        while true {
            skipWhitespaceAndNewlines()
            if idx < input.endIndex && input[idx] == "}" {
                idx = input.index(after: idx)
                break
            }
            let k = try parseIdentifier()
            try expect("=")
            let v = try parseValue()
            dict[k] = v
        }
        return dict
    }

    private var position: Int {
        return input.distance(from: input.startIndex, to: idx)
    }
}

private extension Character {
    var isWhitespaceOrNewline: Bool {
        return isWhitespace || isNewline
    }
}
