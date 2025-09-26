import Foundation

public enum VersionPrefixStyle {
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
