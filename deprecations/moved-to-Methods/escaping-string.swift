import Foundation

public enum EscapeKind {
    case line
    case block

    public var esc: String {
        switch self {
            case .line:
                return "\""
            case .block:
                return "\"\"\""
        }
    }

    public static func escape(_ s: String, kind: EscapeKind) -> String {
        let normalized = s.replacingOccurrences(of: "\"", with: "\\\"")
        switch kind {
        case .line:
            return [
                kind.esc,
                normalized,
                kind.esc,
            ].joined()
        case .block: 
            return [
                kind.esc,
                normalized,
                kind.esc,
            ].joined(separator: "\n")
        }
    }
}

extension String {
    public func escape(_ kind: EscapeKind = .line) -> String {
        return EscapeKind.escape(self, kind: kind)
    }
}
