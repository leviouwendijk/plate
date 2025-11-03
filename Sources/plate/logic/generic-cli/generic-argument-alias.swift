import Foundation

enum GenericArgumentAliasType {
    case short
    case long

    var prefix: String {
        switch self {
        case .short:
            return "-"
        case .long:
            return "--"
        }
    }
}

struct GenericArgumentAlias {
    let type: GenericArgumentAliasType
    let name: String

    var identifier: String {
        return type.prefix + name
    }
}
