import Foundation

/// Key configurations
extension EnvironmentExtractable {
    /// Default to `.auto` so conformers don't have to implement `var key`.
    public var key: EnvironmentExtractableKey { .auto }

    public func infer() -> String {
        self
        .rawValue
        .snake()
        .uppercased()
    }

    private var resolvedKey: String {
        switch key {
        case .symbol(let s): return s
        case .auto:          return infer()
        }
    }
}

/// Value configurations
extension EnvironmentExtractable {
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
