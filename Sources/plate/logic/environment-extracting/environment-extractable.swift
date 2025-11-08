import Foundation

public protocol EnvironmentExtractable: RawRepresentable, CaseIterable, Sendable, Hashable where RawValue == String {
    var key: EnvironmentExtractableKey { get }
    func infer() -> String
    func get(_ key: String) throws -> String
}

public enum EnvironmentExtractableKey: Sendable, Codable {
    case symbol(String)
    case auto
}

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


extension EnvironmentExtractable {
    /// Default to `.auto` so conformers don't have to implement `var key`.
    public var key: EnvironmentExtractableKey { .auto }

    public func infer() -> String {
        self
        .rawValue
        .snake()
        .uppercased()
    }

    /// Default throwing fetch using process environment.
    public func get(_ key: String) throws -> String {
        guard let raw = ProcessInfo.processInfo.environment[key] else {
            throw EnvironmentExtractableError.missing(key)
        }
        guard !raw.isEmpty else {
            throw EnvironmentExtractableError.empty(key)
        }
        return raw
    }

    private var resolvedKey: String {
        switch key {
        case .symbol(let s): return s
        case .auto:          return infer()
        }
    }

    /// Fetch the value for this case (throws if missing/empty).
    public func value() throws -> String {
        return try get(resolvedKey)
    }

    /// Lossless typed fetch.
    public func value<T: LosslessStringConvertible>(as: T.Type = T.self) throws -> T {
        let s = try value()
        guard let converted = T(s) else {
            // Keep semantics simple: treat unparseable as invalid
            throw EnvironmentExtractableError.empty(resolvedKey)
        }
        return converted
    }

    /// Optional soft fetch.
    public func optionalValue() -> String? {
        (try? value())
    }

    /// Common typed helpers.
    public func boolValue() throws -> Bool {
        let v = try value().lowercased()
        switch v {
        case "1", "true", "yes", "y", "on":  return true
        case "0", "false", "no", "n", "off": return false
        default: throw EnvironmentExtractableError.empty(resolvedKey)
        }
    }

    public func intValue() throws -> Int { try value(as: Int.self) }
    public func doubleValue() throws -> Double { try value(as: Double.self) }
}

public extension Collection where Element: EnvironmentExtractable {
    /// Validate a set of keys at once; returns `[Element: String]`.
    func validate() throws -> [Element: String] {
        var out: [Element: String] = [:]
        out.reserveCapacity(self.count)
        for k in self {
            out[k] = try k.value()
        }
        return out
    }
}
