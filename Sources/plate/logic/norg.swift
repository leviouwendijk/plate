// adapted from scripts/swift-text-formatter
import Foundation

#if os(macOS)
import AppKit
#endif

func logVerbose(_ message: String, verbose: Bool = false) {
    if verbose {
        print("[VERBOSE] \(message)")
    }
}

#if os(macOS)
public enum NorgTokenType: CustomStringConvertible {
    case bold(String)
    case italic(String)
    case plain(String)
    case header(String)
    case emptyLine
    case inlineFootnoteReference(String) // e.g., {^ 1}
    case singleFootnote(String, String) // Title, Content
    case multiFootnote(String, String)         // Entire Content

    public var description: String {
        switch self {
        case .bold(let text):
            return "Bold: \"\(text)\""
        case .italic(let text):
            return "Italic: \"\(text)\""
        case .plain(let text):
            return "Plain: \"\(text)\""
        case .header(let text):
            return "Header: \"\(text)\""
        case .emptyLine:
            return "Empty Line"
        case .inlineFootnoteReference(let title):
            return "Inline Footnote Reference: \"\(title)\""
        case .singleFootnote(let title, let content):
            return "Single Footnote: Title=\"\(title)\", Content=\"\(content)\""
        case .multiFootnote(let title, let content):
            return "Multi Footnote: Title=\"\(title)\", Content=\"\(content)\""
        }
    }
}

extension Array where Element == NorgTokenType {
    public func formattedDescription() -> String {
        self.map { $0.description }.joined(separator: "\n")
    }
}

private func matchHeader(_ line: Substring) -> String? {
    let text = String(line)
    let regex = try! NSRegularExpression(pattern: #"^(\*{1,7}) (.+)"#)
    let nsrange = NSRange(text.startIndex..<text.endIndex, in: text)

    guard
        let match = regex.firstMatch(in: text, options: [], range: nsrange),
        let headerRange = Range(match.range(at: 2), in: text)
    else {
        return nil
    }

    return String(text[headerRange])
}

private func matchFootnote(_ line: Substring) -> NorgTokenType? {
    let text = String(line)
    let nsrange = NSRange(text.startIndex..<text.endIndex, in: text)

    let singleFootnoteRegex      = try! NSRegularExpression(pattern: #"^\^\s*(\d+)$"#)
    let multiFootnoteStartRegex  = try! NSRegularExpression(pattern: #"^\^\^\s*(\d+)\s*(.+)?$"#)
    let multiFootnoteEndRegex    = try! NSRegularExpression(pattern: #"^\^\^$"#)

    if let singleMatch = singleFootnoteRegex.firstMatch(in: text, options: [], range: nsrange) {
        guard let titleRange = Range(singleMatch.range(at: 1), in: text) else {
            return nil
        }
        let title = String(text[titleRange])
        return .singleFootnote(title, "")
    }

    if let multiMatch = multiFootnoteStartRegex.firstMatch(in: text, options: [], range: nsrange) {
        guard let titleRange = Range(multiMatch.range(at: 1), in: text) else {
            return nil
        }
        let title = String(text[titleRange])

        let content: String
        if multiMatch.range(at: 2).location != NSNotFound,
           let contentRange = Range(multiMatch.range(at: 2), in: text) {
            content = String(text[contentRange])
        } else {
            content = ""
        }

        return .multiFootnote(title, content)
    }

    if multiFootnoteEndRegex.firstMatch(in: text, options: [], range: nsrange) != nil {
        return .multiFootnote("END_MULTI", "")
    }

    return nil
}

// Parse inline formatting (*bold*, /italic/, plain text, {^ x})
private func parseInlineFormatting(_ text: String) -> [NorgTokenType] {
    var tokens: [NorgTokenType] = []
    var currentIndex = text.startIndex
    logVerbose("Parsing inline formatting for text: \(text).") 

    // Match *bold*, /italic/, {^ x} (inline footnotes), smart quotes, em dash, and contractions
    let regex = try! NSRegularExpression(
        // former versions:
        // pattern: #"\*(.*?)\*|\/(.*?)\/|\{\^ (\d+)\}|(--|—)|(['\"])(.*?)\5|(\b\w+'\w+\b)|(')"#,
        // pattern: #"\*(.*?)\*|\/(.*?)\/|\{\^ (\d+)\}|(--|—)|(['\"])(.*?)\5|(\b\w+'\w+\b)|(\w+'\b)|(')"#, 
        pattern: #"\*(.*?)\*|\/(.*?)\/|\{\^ (\d+)\}|(--|—)|(['\"])(.*?)\5|(\b\w+'\w+\b)|(\b\w+')"#, 
        options: []
    )
    let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

    for match in matches {
        let matchRange = match.range
        let beforeMatchRange = currentIndex..<text.index(text.startIndex, offsetBy: matchRange.lowerBound)

        // Add plain text before each match
        if !beforeMatchRange.isEmpty {
            let plainText = String(text[beforeMatchRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            logVerbose("Adding plain text token: \(plainText).") 
            tokens.append(.plain(plainText))
        }

        // Process matched token
        if let boldRange = Range(match.range(at: 1), in: text) {
            logVerbose("Adding bold token: \(text[boldRange]).") 
            tokens.append(.bold(String(text[boldRange])))
        } else if let italicRange = Range(match.range(at: 2), in: text) {
            logVerbose("Adding italic token: \(text[italicRange]).") 
            tokens.append(.italic(String(text[italicRange])))
        } else if let footnoteRefRange = Range(match.range(at: 3), in: text) {
            logVerbose("Adding inline footnote reference token: \(text[footnoteRefRange]).") 
            tokens.append(.inlineFootnoteReference(String(text[footnoteRefRange])))
        } else if match.range(at: 4).location != NSNotFound { // Em dash
            logVerbose("Adding em dash token.") 
            tokens.append(.plain("—")) // Directly add the em dash
        } else if let quoteTypeRange = Range(match.range(at: 5), in: text),
                  let quoteContentRange = Range(match.range(at: 6), in: text) {
            let quoteType = text[quoteTypeRange]
            let quoteContent = text[quoteContentRange]
            if quoteType == "\"" { // Double quotes
                logVerbose("Adding double quotes token with content: \(quoteContent).") 
                tokens.append(.plain("“\(quoteContent)”"))
            } else if quoteType == "'" { // Single quotes
                logVerbose("Adding single quotes token with content: \(quoteContent).") 
                tokens.append(.plain("‘\(quoteContent)’"))
            }
        } else if let contractionRange = Range(match.range(at: 7), in: text) { // Contractions
            let contractionText = String(text[contractionRange])
            let smartApostrophe = contractionText.replacingOccurrences(of: "'", with: "’") // Convert apostrophe to smart apostrophe
            logVerbose("Adding contraction token: \(smartApostrophe).")
            tokens.append(.plain(smartApostrophe))
        } else if let possessiveRange = Range(match.range(at: 8), in: text) { // Standalone possessives
            let possessiveText = String(text[possessiveRange])
            logVerbose("Adding possessive token for standalone: \(possessiveText).")

            // Add possessive with smart apostrophe as a single token
            let possessiveWithSmartApostrophe = possessiveText.replacingOccurrences(of: "'", with: "’")
            tokens.append(.plain(possessiveWithSmartApostrophe))
        } else if match.range(at: 9).location != NSNotFound { // Standalone single apostrophe
            logVerbose("Adding standalone apostrophe token.")
            tokens.append(.plain("’")) // Convert to typographic apostrophe
        }

        // Move current index to after the match
        currentIndex = text.index(text.startIndex, offsetBy: matchRange.upperBound)
    }

    // Add remaining plain text
    if currentIndex < text.endIndex {
        tokens.append(.plain(String(text[currentIndex...])))
    }

    logVerbose("Inline formatting parsing complete. Total tokens: \(tokens.count).") 
    return tokens
}

// Helper function to determine if a space is needed between two tokens
private func needsSpaceBetween(_ previous: NorgTokenType, _ current: NorgTokenType) -> Bool {
    switch (previous, current) {
    case (.plain(let prevText), .plain(let currText)):
        // Special case: Remove space between quotes and punctuation
        if prevText.last == "”" || prevText.last == "’" {
            if currText.first == "," || currText.first == "." || currText.first == ";" || currText.first == ":" {
                return false
            }
        }
        // Special case: Remove space around em dashes
        if prevText.hasSuffix("—") || currText.hasPrefix("—") {
            return false
        }
        // Check if the plain text naturally ends with or starts with a space
        return !prevText.hasSuffix(" ") && !currText.hasPrefix(" ")
    case (.italic, .plain(let currText)), (.bold, .plain(let currText)):
        // Remove space between styled text and plain text starting with em dash
        if currText.hasPrefix("—") {
            return false
        }
        
        if currText.first == "," || currText.first == "." || currText.first == ";" || currText.first == ":" ||
            currText.first == "!" || currText.first == "?" {
            return false
        }
        // Add space otherwise
        return true
    case (.plain(let prevText), .italic), (.plain(let prevText), .bold):
        // Remove space between plain text ending with punctuation and styled text
        if prevText.hasSuffix("—") || prevText.last == "“" || prevText.last == "(" {
            return false
        }
        // Add space otherwise
        return !prevText.hasSuffix(" ")
    case (.italic, .italic), (.bold, .bold):
        // Never add space between consecutive styled tokens
        return false
    default:
        // For all other cases, maintain the default behavior
        return true
    }
}

public struct NorgParser {
    public static func tokenize(_ text: String, verbose: Bool = false) -> [NorgTokenType] {
        var tokens: [NorgTokenType] = []

        // Remove metadata block
        let cleanedText = text.replacingOccurrences(of: #"(?s)@document\.meta.*?@end"#, with: "", options: .regularExpression)

        // Process line by line
        let lines = cleanedText.split(separator: "\n", omittingEmptySubsequences: false)
        logVerbose("Split text into \(lines.count) lines.")
        var isMultiFootnote = false
        var multiFootnoteTitle: String = ""
        var multiFootnoteContent: String = ""
        var pendingSingleFootnote: (String, String)? = nil // Holds (title, content)

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces) // Trim leading/trailing spaces
            logVerbose("Processing line: \(trimmedLine)")

            // Handle multi-paragraph footnotes
            if isMultiFootnote {
                if trimmedLine.starts(with: "^^") { // Multi-footnote ends
                    tokens.append(.multiFootnote(multiFootnoteTitle, multiFootnoteContent.trimmingCharacters(in: .whitespacesAndNewlines)))
                    isMultiFootnote = false
                    multiFootnoteTitle = ""
                    multiFootnoteContent = ""
                } else {
                    multiFootnoteContent += trimmedLine + "\n" // Add line to multi-footnote content
                }
                continue
            }

            // Handle pending single-paragraph footnote content
            if let (title, _) = pendingSingleFootnote {
                if !trimmedLine.starts(with: "^") { // Content for single footnote
                    tokens.append(.singleFootnote(title, trimmedLine))
                    pendingSingleFootnote = nil
                    continue
                }
            }

            if trimmedLine.isEmpty {
                logVerbose("Detected empty line.")
                tokens.append(.emptyLine) // Add an empty line token
            } else if let headerMatch = matchHeader(trimmedLine[...]) {
                logVerbose("Detected header: \(headerMatch).") 
                tokens.append(.header(headerMatch)) // Match headers with varying levels
            } else if let footnoteMatch = matchFootnote(trimmedLine[...]) {
                logVerbose("Detected footnote: \(footnoteMatch).") 
                switch footnoteMatch {
                case .singleFootnote(let title, _):
                    pendingSingleFootnote = (title, "") // Wait for content in the next line
                case .multiFootnote(let title, let content):
                    isMultiFootnote = true // Start collecting multi-footnote content
                    multiFootnoteTitle = title
                    multiFootnoteContent = content + "\n"
                default:
                    tokens.append(footnoteMatch)
                }
            } else {
                // Parse inline formatting for bold, italic, and inline footnotes
                let inlineTokens = parseInlineFormatting(trimmedLine)
                logVerbose("Parsed inline formatting into \(inlineTokens.count) tokens.") 
                tokens.append(contentsOf: inlineTokens)
            }
        }

        // Finalize any leftover multi-footnote content
        if isMultiFootnote {
            logVerbose("Finalizing multi-footnote with title: \(multiFootnoteTitle).") 
            tokens.append(.multiFootnote(multiFootnoteTitle, multiFootnoteContent.trimmingCharacters(in: .whitespacesAndNewlines)))
        }

        logVerbose("Tokenization complete. Total tokens: \(tokens.count).") 
        return tokens
    }

    // public func convertTokensToAttributedString(_ tokens: [NorgTokenType]) -> NSAttributedString {
    public static func attributedString(_ tokens: [NorgTokenType], verbose: Bool = false) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        var previousToken: NorgTokenType? = nil

        for token in tokens {
            switch token {
            case .bold(let text):
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
                ]
                if let prev = previousToken, needsSpaceBetween(prev, token) {
                    attributedString.append(NSAttributedString(string: " "))
                }
                attributedString.append(NSAttributedString(string: text, attributes: attributes))
            case .italic(let text):
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: NSFontManager.shared.convert(NSFont.systemFont(ofSize: NSFont.systemFontSize), toHaveTrait: .italicFontMask)
                ]
                if let prev = previousToken, needsSpaceBetween(prev, token) {
                    attributedString.append(NSAttributedString(string: " "))
                }
                attributedString.append(NSAttributedString(string: text, attributes: attributes))
            case .header(let text):
                // Determine header level based on asterisks
                let level = text.prefix(while: { $0 == "*" }).count
                let fontSize = NSFont.systemFontSize + CGFloat(max(6 - level, 0)) // Smaller font for higher levels
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.boldSystemFont(ofSize: fontSize)
                ]
                // Add double newline for headers
                attributedString.append(NSAttributedString(string: text.trimmingCharacters(in: .whitespaces) + "\n", attributes: attributes)) // potentially modify the enter line to double enter line if desired?
            case .plain(let text):
                if let prev = previousToken, needsSpaceBetween(prev, token) {
                    attributedString.append(NSAttributedString(string: " "))
                }
                attributedString.append(NSAttributedString(string: text))
            case .emptyLine:
                attributedString.append(NSAttributedString(string: "\n\n"))
            case .inlineFootnoteReference(let reference):
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: NSFont.systemFontSize - 2),
                    .foregroundColor: NSColor.blue
                ]
                attributedString.append(NSAttributedString(string: "[\(reference)]", attributes: attributes)) // Render as [1], [2], etc.
            case .singleFootnote(let title, let content):
                // Attributes for the title of the footnote
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize - 2), // Slightly smaller font
                    .foregroundColor: NSColor.darkGray // Different color for emphasis
                ]
                // Attributes for the content of the footnote
                let contentAttributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: NSFont.systemFontSize - 2),
                    .foregroundColor: NSColor.gray
                ]
                // Append title and content
                attributedString.append(NSAttributedString(string: "Footnote: \(title)\n", attributes: titleAttributes))
                attributedString.append(NSAttributedString(string: content + "\n\n", attributes: contentAttributes))

            case .multiFootnote(let title, let content):
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize - 2),
                    .foregroundColor: NSColor.darkGray
                ]
                let contentAttributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: NSFont.systemFontSize - 2),
                    .foregroundColor: NSColor.gray
                ]
                attributedString.append(NSAttributedString(string: "Footnote [\(title)]:\n", attributes: titleAttributes))
                attributedString.append(NSAttributedString(string: content + "\n\n", attributes: contentAttributes))
            }
            previousToken = token
        }

        return attributedString
    }
}

extension String {
    /// “One-liner” to get a styled NSAttributedString from Norg
    public func toNorgAttributedString(verbose: Bool = false) -> NSAttributedString {
        let tokens = NorgParser.tokenize(self, verbose: verbose)
        return NorgParser.attributedString(tokens, verbose: verbose)
    }

    /// And if you want HTML instead:
    public func toNorgHTML(verbose: Bool = false) throws -> String {
        let attr = toNorgAttributedString(verbose: verbose)
        let opts: [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let data = try attr.data(
                from: NSRange(location: 0, length: attr.length),
                documentAttributes: opts
        )
        guard let html = String(data: data, encoding: .utf8) else {
            throw NSError(
                    domain: "NorgKit", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Couldn’t encode HTML"]
            )
        }

        return html
    }
}

// func main() {
//     print("")
//     var log = ""

//     let args = CommandLine.arguments

//     // Validate command-line arguments
//     guard args.count >= 2 else {
//         print("Usage: stf <input-file.norg> [-verbose]")
//         exit(1)
//     }

//     if args.contains("-verbose") {
//         verbose = true
//         logVerbose("Verbose mode activated.") 
//     }

//     let inputPath = args[1]

//     // Read input file
//     guard let content = readFile(at: inputPath) else {
//         log.append("Failed to read input file.")
//         exit(1)
//     }

//     // Tokenize and convert to attributed string
//     let tokens = tokenize(content)
//     log.append("Tokens:\n\(tokens.formattedDescription())\n".ansi(.brightBlack))
//     let attributedString = convertTokensToAttributedString(tokens)
//     print(log)

//     copyNSToClipboard(attributedString)
//     print("Formatted text copied to clipboard.")
//     print("")
// }
#endif
