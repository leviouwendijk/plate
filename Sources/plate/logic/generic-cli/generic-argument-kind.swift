import Foundation

public enum GenericArgumentKind {
    case flag(action: () -> Void)
    case option(action: (_ value: String) -> Void)
    case optionalOption(action: (_ value: String?) -> Void)
}

// public struct GenericArgumentAction {
//     let void: (() -> Void)? = nil
//     let value: ((_ value: String) -> Void)? = nil
//     let optional_value: ((_ value: String?) -> Void)? = nil

//     let throwing_void: (() throws -> Void)? = nil
//     let throwing_value: ((_ value: String) throws -> Void)? = nil
//     let throwing_optional_value: ((_ value: String?) throws -> Void)? = nil
// }
