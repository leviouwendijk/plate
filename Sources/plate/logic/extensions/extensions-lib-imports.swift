import Foundation
import Contacts

extension String {
    public func convertingReplacements(
        replacements: [StringTemplateReplacement],
        replaceEmpties: Bool = false
    ) -> String {
        let converter = StringTemplateConverter(
            text: self,
            replacements: replacements
        )

        return converter.replace(replaceEmpties: replaceEmpties)
    }
}

extension String {
    public func htmlClean() -> String {
        return self
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    public func viewableEndpointString() -> String {
        return "/\(self)"
        .replacingOccurrences(of: "/", with: " / ")
    }

    public func viewableURLString() -> String {
        return "\(self)"
        .replacingOccurrences(of: "/", with: " / ")
        .replacingOccurrences(of: "/  /", with: "//")
    }
}

extension String {
    public var replacePipesWithWhitespace: String {
        return self.replacingOccurrences(of: "|", with: " ")
    }

    public var normalizedForClientDogSearch: String {
        return self
        .folding(options: .diacriticInsensitive, locale: .current)
        .replacePipesWithWhitespace
        .components(separatedBy: CharacterSet.whitespacesAndNewlines)
        .filter { !$0.isEmpty }
        .joined(separator: " ")
        .lowercased()
    }

    public func replaceClientDogTemplatePlaceholders(
        client: String,
        dog: String,
        placeholderSyntax: PlaceholderSyntax = PlaceholderSyntax(
            prepending: "{", 
            appending: "}", 
            repeating: 2
        )
    ) -> String {
        let replacements: [StringTemplateReplacement] = [
            StringTemplateReplacement(
                placeholders: ["client", "name"],
                replacement: client,
                initializer: .auto,
                placeholderSyntax: placeholderSyntax
            ),
            StringTemplateReplacement(
                placeholders: ["dog"],
                replacement: dog,
                initializer: .auto,
                placeholderSyntax: placeholderSyntax
            ),
        ]

        let converter = StringTemplateConverter(
            text: self,
            replacements: replacements
        )

        return converter.replace()
    }

    public var commaSeparatedValuesToParsableArgument: String {
        self
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: " ")
    }

    public func firstCapturedGroup(
        pattern: String,
        options: NSRegularExpression.Options = []
    ) -> String? {
        guard let re = try? NSRegularExpression(pattern: pattern, options: options) else { return nil }
        let ns = self as NSString
        let full = NSRange(location: 0, length: ns.length)
        guard let m = re.firstMatch(in: self, options: [], range: full), m.numberOfRanges >= 2 else { return nil }
        return ns.substring(with: m.range(at: 1))
    }

    public var commaSeparatedValuesToList: [String] {
        self
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
    }

    public func containsRawTemplateVariables(ignoring exceptions: [String] = []) -> Bool {
        let pattern = #"\{\{\s*([^}]+?)\s*\}\}"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        
        let nsString = self as NSString
        let fullRange = NSRange(location: 0, length: nsString.length)
        let matches = regex.matches(in: self, options: [], range: fullRange)
        
        for match in matches {
            let contentRange = match.range(at: 1)
            let rawContent = nsString.substring(with: contentRange)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let firstToken = rawContent
                .components(separatedBy: .whitespaces)
                .first ?? ""
            
            if !exceptions.contains(firstToken) {
                return true
            }
        }
        return false
    }

    public func containsRawTemplatePlaceholderSyntaxes(
        ignoring exceptions: [String] = [],
        placeholderSyntaxes syntaxes: [PlaceholderSyntax] = [
            .init(prepending: "{", appending: "}", repeating: 2), // `{{ … }}`
            .init(prepending: "{", appending: "}"),               // `{ … }`
            .init(prepending: "${", appending: "}"),              // `${ … }`
        ]
    ) -> Bool {
        let ignoreSet = Set(exceptions)
        
        for syntax in syntaxes {
            let openDelim  = syntax.prefix
            let closeDelim = syntax.suffix

            // debug
            // print("open delimiter = ", openDelim)
            // print("closing delimiter = ", closeDelim)
            
            var scanStart = startIndex
            while true {
                guard let openRange = self.range(of: openDelim, range: scanStart..<endIndex) else {
                    break
                }
                
                let afterOpen = openRange.upperBound
                guard let closeRange = self.range(of: closeDelim, range: afterOpen..<endIndex) else {
                    break
                }
                
                let innerRange = afterOpen..<closeRange.lowerBound
                let rawContent = self[innerRange].trimmingCharacters(in: .whitespacesAndNewlines)
                
                let firstToken = rawContent
                    .split(whereSeparator: { $0.isWhitespace })
                    .first
                    .map(String.init) ?? ""
                
                if !ignoreSet.contains(firstToken) {
                    return true
                }

                scanStart = closeRange.upperBound
            }
        }
        return false
    }

    public func extractingRawTemplatePlaceholderSyntaxes(
        ignoring exceptions: [String] = [],
        placeholderSyntaxes syntaxes: [PlaceholderSyntax] = [
            .init(prepending: "{", appending: "}", repeating: 2), // `{{ … }}`
            .init(prepending: "{", appending: "}"),               // `{ … }`
            .init(prepending: "${", appending: "}"),              // `${ … }`
        ]
    ) -> [String] {
        let ignoreSet = Set(exceptions)
        var rawPlaceholders: [String] = []
        
        for syntax in syntaxes {
            let openDelim  = syntax.prefix
            let closeDelim = syntax.suffix
            
            var scanStart = startIndex
            while true {
                guard let openRange = self.range(of: openDelim, range: scanStart..<endIndex) else {
                    break
                }
                
                let afterOpen = openRange.upperBound
                guard let closeRange = self.range(of: closeDelim, range: afterOpen..<endIndex) else {
                    break
                }
                
                let innerRange = afterOpen..<closeRange.lowerBound
                let rawContent = self[innerRange].trimmingCharacters(in: .whitespacesAndNewlines)
                
                let firstToken = rawContent
                    .split(whereSeparator: { $0.isWhitespace })
                    .first
                    .map(String.init) ?? ""
                
                if !ignoreSet.contains(firstToken) {
                    rawPlaceholders.append(firstToken)
                }

                scanStart = closeRange.upperBound
            }
        }
        return rawPlaceholders
    }
}
