import Foundation

public struct SyntheticSymbolOptions: Sendable {
    public var name: String
    public var suffix: SynthesizedSymbol
    public var style: CaseStyle
    public var infix: String?
    public var formatting: KeyFormattingStrategy
    
    public init(
        name: String,
        suffix: SynthesizedSymbol = .api_key,
        style: CaseStyle = .snake,
        infix: String? = "_",
        formatting: KeyFormattingStrategy = .uppercased
    ) {
        self.name = name
        self.suffix = suffix
        self.style = style
        self.infix = infix
        self.formatting = formatting
    }
}

public enum SynthesizedSymbol: String, RawRepresentable, Sendable, Codable {
    case api_key
    case token
    case bearer
    case public_key_path
    case private_key_path
    case db_name
    case db_user
    case db_passwd
    case webhook_url

    public static func synthesize(
        options: SyntheticSymbolOptions
    ) -> String {
        var res: [String] = [options.name]

        if let infix = options.infix {
            res.append(infix)
        }

        res.append(options.suffix.rawValue)
        let joined = res.joined()
        let styled = convertIdentifier(joined, to: options.style)
        let formatted = options.formatting.apply(styled)
        return formatted
    }
}
