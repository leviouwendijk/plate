import Foundation

#if os(macOS)
public enum EnvironmentExtractableError: Error, LocalizedError, Sendable, Equatable {
    case missing(String)
    case empty(String)
    case inferenceRequired            // `.auto` used without an infer fallback

    public var errorDescription: String? {
        switch self {
        case .missing(let k): return "Environment variable not found: \(k)"
        case .empty(let k):   return "Environment variable is empty: \(k)"
        case .inferenceRequired: return "Inference required for `.auto` environment key."
        }
    }

    public var failureReason: String? { errorDescription }
    public var recoverySuggestion: String? {
        switch self {
        case .inferenceRequired:
            return "Provide an `infer:` fallback or use `.symbol(\"NAME\")`."
        default:
            return "Define the variable in your runtime environment and restart the process."
        }
    }
}
#endif
