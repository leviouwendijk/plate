import Foundation

public extension Character {
    var isWhitespaceOrNewline: Bool {
        return isWhitespace || isNewline
    }
}

public class PklParser {
    public let input: String
    public var idx: String.Index

    public init(_ text: String) {
        self.input = text
        self.idx = text.startIndex
    }

    public func expect(_ char: Character) throws {
        skipWhitespaceAndNewlines()
        guard idx < input.endIndex else {
            throw PklParserError.syntaxError(
                "Unexpected EOF: expected '\(char)'"
            )
        }
        let found = input[idx]
        guard found == char else {
            throw PklParserError.syntaxError(
                "Expected '\(char)' but found '\(found)' at pos \(position)"
            )
        }
        idx = input.index(after: idx)
    }

    @discardableResult
    public func skipWhitespaceAndNewlines() -> Bool {
        _ = idx
        while idx < input.endIndex && input[idx].isWhitespaceOrNewline {
            idx = input.index(after: idx)
        }

        ignoreComments()

        return idx < input.endIndex
    }

    @discardableResult
    public func ignoreComments() -> Bool {
        while idx < input.endIndex {
            // Detect //
            if input[idx] == "/" {
                let next = input.index(after: idx)
                if next < input.endIndex, input[next] == "/" {
                    // Skip "//"
                    idx = input.index(after: next)

                    // Skip until newline / EOF
                    while idx < input.endIndex, !input[idx].isNewline {
                        idx = input.index(after: idx)
                    }

                    // After skipping, allow skipWhitespace to clear newline
                    while idx < input.endIndex, input[idx].isWhitespaceOrNewline {
                        idx = input.index(after: idx)
                    }

                    // Continue looping in case another comment follows
                    continue
                }
            }
            break
        }

        return idx < input.endIndex
    }

    public var position: Int {
        return input.distance(from: input.startIndex, to: idx)
    }

    public func reset() { idx = input.startIndex }
}
