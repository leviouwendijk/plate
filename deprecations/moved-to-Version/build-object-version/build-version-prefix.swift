import Foundation

public enum VersionPrefixStyle: Sendable, Codable {
    case short
    case long
    case none

    public func prefix() -> String {
        switch self {
            case .short:
                return "v"
            case .long:
                return "version"
            case .none:
                return ""
        }
    }
}
