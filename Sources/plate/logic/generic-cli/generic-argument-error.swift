import Foundation

enum GenericArgumentError: Error, LocalizedError {
    case unrecognizedGenericArgument(String, Int)
    case missingValue(forFlag: String)
    case invalidCombination(String)
    case noGenericArgumentsRegisteredAtRuntime

    var errorDescription: String? {
        switch self {
        case let .unrecognizedGenericArgument(arg, pos):
            return "Unrecognized argument: '\(arg)' at position \(pos)"
        case let .missingValue(forFlag):
            return "Missing value for option \(forFlag)"
        case let .invalidCombination(combo):
            return "Invalid short-flag combination: \(combo)"
        case .noGenericArgumentsRegisteredAtRuntime:
            return "No arguments are registered in the program's runtime"
        }
    }
}
