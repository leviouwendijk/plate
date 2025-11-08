import Foundation

public enum EnvironmentExtractableError: Error, LocalizedError, Sendable, Equatable {
    case missing(String)
    case empty(String)

    public var errorDescription: String? {
        switch self {
        case .missing(let k): return "Environment variable not found: \(k)"
        case .empty(let k):   return "Environment variable is empty: \(k)"
        }
    }

    public var failureReason: String? { errorDescription }

    public var recoverySuggestion: String? {
        "Define the variable in your runtime environment and restart the process."
    }
}
