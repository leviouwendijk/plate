import Foundation

// extension EnvironmentResolvable {
//     public func infer(_ string: String) -> String {
//         string
//         .snake()
//         .uppercased()
//     }
// }

#if os(macOS)
extension EnvironmentResolvable {
    public func get(
        _ name: String,
        replacer: EnvironmentReplacer = .init()
    ) throws -> String {
        guard let raw = ProcessInfo.processInfo.environment[name] else {
            throw EnvironmentExtractableError.missing(name)
        }
        guard !raw.isEmpty else {
            throw EnvironmentExtractableError.empty(name)
        }
        if !replacer.replacements.isEmpty {
            return replacer.apply(to: raw)
        }
        return raw
    }

    // Resolve a key with a provided fallback for `.auto`
    public func value(
        for key: EnvironmentExtractableKey,
        infer name: @autoclosure () -> String,
        replacer: EnvironmentReplacer = .init()
    ) throws -> String {
        switch key {
        case .symbol(let s): return try get(s, replacer: replacer)
        case .auto:          return try get(name(), replacer: replacer)
        }
    }

    public func value<T: LosslessStringConvertible>(
        for key: EnvironmentExtractableKey,
        as: T.Type = T.self,
        infer name: @autoclosure () -> String,
        replacer: EnvironmentReplacer = .init()
    ) throws -> T {
        let s = try value(for: key, infer: name(), replacer: replacer)
        guard let t = T(s) else { throw EnvironmentExtractableError.empty((keyName(key) ?? name())) }
        return t
    }

    public func bool(
        for key: EnvironmentExtractableKey,
        infer name: @autoclosure () -> String,
    ) throws -> Bool {
        let n = keyName(key) ?? name()
        let v = try get(n).lowercased()
        switch v {
        case "1", "true", "yes", "y", "on":  return true
        case "0", "false", "no", "n", "off": return false
        default: throw EnvironmentExtractableError.empty(n)
        }
    }

    // Soft variants
    public func optional(
        for key: EnvironmentExtractableKey,
        infer name: @autoclosure () -> String,
        replacer: EnvironmentReplacer = .init()
    ) -> String? {
        (try? value(for: key, infer: name(), replacer: replacer))
    }

    private func keyName(_ key: EnvironmentExtractableKey) -> String? {
        if case let .symbol(s) = key { return s }
        return nil
    }
}
#endif
