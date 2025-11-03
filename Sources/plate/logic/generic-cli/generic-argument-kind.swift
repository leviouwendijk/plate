import Foundation

public enum GenericArgumentKind {
    case flag(action: () -> Void)
    case option(action: (_ value: String) -> Void)
    case optionalOption(action: (_ value: String?) -> Void)
}
