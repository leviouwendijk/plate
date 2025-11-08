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
    // Instance conveniences built on top of the generic layer
    public func value() throws -> String {
        try value(for: key, infer: resolvedKey)
    }

    public func value<T: LosslessStringConvertible>(as: T.Type = T.self) throws -> T {
        try value(for: key, as: T.self, infer: resolvedKey)
    }

    public func optionalValue() -> String? {
        optional(for: key, infer: resolvedKey)
    }

    public func boolValue() throws -> Bool {
        try bool(for: key, infer: resolvedKey)
    }

    public func intValue() throws -> Int { try value(as: Int.self) }
    public func doubleValue() throws -> Double { try value(as: Double.self) }
}

extension Collection where Element: EnvironmentExtractable {
    /// Validate a set of keys at once; returns `[Element: String]`.
    public func validate() throws -> [Element: String] {
        var out: [Element: String] = [:]
        out.reserveCapacity(self.count)
        for k in self {
            out[k] = try k.value()
        }
        return out
    }
}
