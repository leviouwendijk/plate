import Foundation

public enum PlaceholderInitializationType {
    case manual
    case auto
}

public struct PlaceholderSyntax {
    public let prepending: String
    public let appending: String
    public let repeating: Int

    public init(
        prepending: String,
        appending: String = "",
        repeating: Int = 1
    ) {
        self.prepending = prepending
        self.appending = appending
        self.repeating = repeating
    }

    public func set(for str: String) -> String {
        let pre = String(repeating: prepending, count: repeating)
        let app = String(repeating: appending, count: repeating)
        return "\(pre)\(str)\(app)"
    }
}

public struct StringTemplateReplacement {
    public let placeholders: [String]
    public let replacement: String

    public init(
        placeholders: [String],
        replacement: String = "",
        initializer: PlaceholderInitializationType = .manual,
        placeholderSyntax: PlaceholderSyntax = PlaceholderSyntax(prepending: "{{", appending: "}}")
    ) {
        var p: [String] = []

        switch initializer {
            case .manual:
                p = placeholders
            case .auto:
                for i in placeholders {
                    let autoInitializedPlaceholder = placeholderSyntax.set(for: i)
                    p.append(autoInitializedPlaceholder)
                }
        }

        self.placeholders = p
        self.replacement = replacement
    }
}

public struct StringTemplateConverter {
    public let text: String
    public let replacements: [StringTemplateReplacement]

    public init(
        text: String,
        replacements: [StringTemplateReplacement],
    ) {
        self.text = text
        self.replacements = replacements
    }

    public func replace() -> String {
        var t = text
        
        for r in replacements {
            for p in r.placeholders {
                t = t
                .replaceNotEmptyVariable(
                    replacing: p,
                    with: r.replacement
                )
            }
        }

        return t
    }
}
