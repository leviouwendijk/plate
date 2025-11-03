import Foundation

public enum GenericArgumentAliasType {
    case short
    case long

    public var prefix: String {
        switch self {
        case .short:
            return "-"
        case .long:
            return "--"
        }
    }
}

public struct GenericArgumentAlias {
    public let type: GenericArgumentAliasType
    public let name: String

    public var identifier: String {
        return type.prefix + name
    }
}
