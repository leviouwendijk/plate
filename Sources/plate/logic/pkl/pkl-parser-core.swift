import Foundation

extension PklParser {
    public func parseIdentifier() throws -> String {
        skipWhitespaceAndNewlines()
        let start = idx
        while idx < input.endIndex, input[idx].isLetter {
            idx = input.index(after: idx)
        }
        guard start < idx else {
            let found = idx < input.endIndex ? String(input[idx]) : "EOF"
            throw PklParserError.syntaxError(
              "Expected identifier at pos \(position), found '\(found)'"
            )
        }
        return String(input[start..<idx])
    }

    public func parseValue() throws -> Any {
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
            throw PklParserError.syntaxError(
              "Unexpected value start '\(c)' at pos \(position)"
            )
        }
    }

    public func parseString() throws -> String {
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

    public func parseNumber() throws -> Int {
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

    public func parseBlock() throws -> [String: Any] {
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

    public func parseStringListBlock() throws -> [String] {
        try expect("{")
        var out: [String] = []
        while true {
            skipWhitespaceAndNewlines()
            if idx < input.endIndex, input[idx] == "}" {
                idx = input.index(after: idx)
                break
            }
            guard idx < input.endIndex, input[idx] == "\"" else {
                let found = idx < input.endIndex ? String(input[idx]) : "EOF"
                throw PklParserError.syntaxError("Expected string literal in list at pos \(position), found '\(found)'")
            }
            out.append(try parseString())
            // commas optional; tolerate either commas or just newlines/whitespace
            skipWhitespaceAndNewlines()
            if idx < input.endIndex, input[idx] == "," {
                idx = input.index(after: idx)
            }
        }
        return out
    }
}
