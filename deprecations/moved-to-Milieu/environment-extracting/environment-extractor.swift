import Foundation

public enum EnvironmentExtractor {
    @discardableResult
    public static func value(
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

    public static func value<T: LosslessStringConvertible>(
        _ name: String,
        as: T.Type = T.self,
        replacer: EnvironmentReplacer = .init()
    ) throws -> T {
        let s = try value(name, replacer: replacer)
        guard let t = T(s) else { throw EnvironmentExtractableError.empty(name) }
        return t
    }

    public static func bool(_ name: String) throws -> Bool {
        let v = try value(name).lowercased()
        switch v {
        case "1", "true", "yes", "y", "on":  return true
        case "0", "false", "no", "n", "off": return false
        default: throw EnvironmentExtractableError.empty(name)
        }
    }

    public static func optional(
        _ name: String,
        replacer: EnvironmentReplacer = .init()
    ) -> String? {
        (try? value(name, replacer: replacer))
    }

    public static func optional(
        _ name: String?,
        replacer: EnvironmentReplacer = .init()
    ) -> String? {
        guard let name else { return nil }
        return optional(name, replacer: replacer)
    }

    public static func valueOrDefault(
        _ name: String,
        replacer: EnvironmentReplacer = .init(),
        default: String? = nil,
    ) -> String {
        return (try? value(name, replacer: replacer)) ?? name.debugDescription(default: `default`)
    }

    // -------- Key-only overloads (throws if `.auto`) --------

    @discardableResult
    public static func value(
        _ key: EnvironmentExtractableKey,
        replacer: EnvironmentReplacer = .init()
    ) throws -> String {
        switch key {
        case .symbol(let s): return try value(s, replacer: replacer)
        case .auto:          throw EnvironmentExtractableError.inferenceRequired
        }
    }

    public static func value<T: LosslessStringConvertible>(
        _ key: EnvironmentExtractableKey,
        as: T.Type = T.self,
        replacer: EnvironmentReplacer = .init()
    ) throws -> T {
        switch key {
        case .symbol(let s): return try value(s, as: T.self, replacer: replacer)
        case .auto:          throw EnvironmentExtractableError.inferenceRequired
        }
    }

    public static func bool(_ key: EnvironmentExtractableKey) throws -> Bool {
        switch key {
        case .symbol(let s): return try bool(s)
        case .auto:          throw EnvironmentExtractableError.inferenceRequired
        }
    }

    public static func optional(
        _ key: EnvironmentExtractableKey,
        replacer: EnvironmentReplacer = .init()
    ) -> String? {
        switch key {
        case .symbol(let s): return optional(s, replacer: replacer)
        case .auto:          return nil
        }
    }

    public static func valueOrDefault(
        _ key: EnvironmentExtractableKey,
        replacer: EnvironmentReplacer = .init(),
        default: String? = nil,
    ) -> String {
        switch key {
        case .symbol(let s): 
            return (try? value(key, replacer: replacer)) ?? s.debugDescription(default: `default`)
        case .auto:
            return "[DEBUG]: EnvironmentExtractor method .auto not applicable"
        }
    }

    // -------- Key + infer overloads (required for `.auto`) --------

    @discardableResult
    public static func value(
        _ key: EnvironmentExtractableKey,
        infer name: @autoclosure () -> String,
        replacer: EnvironmentReplacer = .init()
    ) throws -> String {
        switch key {
        case .symbol(let s): return try value(s, replacer: replacer)
        case .auto:          return try value(name(), replacer: replacer)
        }
    }

    public static func value<T: LosslessStringConvertible>(
        _ key: EnvironmentExtractableKey,
        as: T.Type = T.self,
        infer name: @autoclosure () -> String,
        replacer: EnvironmentReplacer = .init()
    ) throws -> T {
        let s = try value(key, infer: name(), replacer: replacer)
        guard let t = T(s) else {
            let n = (keyName(key) ?? name())
            throw EnvironmentExtractableError.empty(n)
        }
        return t
    }

    public static func bool(
        _ key: EnvironmentExtractableKey,
        infer name: @autoclosure () -> String
    ) throws -> Bool {
        let n = keyName(key) ?? name()
        return try bool(n)
    }

    public static func optional(
        _ key: EnvironmentExtractableKey,
        infer name: @autoclosure () -> String,
        replacer: EnvironmentReplacer = .init()
    ) -> String? {
        (try? value(key, infer: name(), replacer: replacer))
    }

    // util
    private static func keyName(_ key: EnvironmentExtractableKey) -> String? {
        if case let .symbol(s) = key { return s }
        return nil
    }
}

extension EnvironmentExtractor {
    internal static func debugDescription(default: String? = nil, _ name: String) -> String {
        return `default` ?? "[DEBUG]: \(name) not found in environment"
    }
}

extension String {
    internal func debugDescription(default: String? = nil) -> String {
        return EnvironmentExtractor.debugDescription(default: `default`, self)
    }
}

extension EnvironmentExtractor {
    @discardableResult
    public static func value(
        name: String,
        suffix: SynthesizedSymbol,
        replacer: EnvironmentReplacer = .init()
    ) throws -> String {
        let symbol = SynthesizedSymbol.synthesize(name: name, suffix: suffix)
        return try value(symbol, replacer: replacer)
    }
}

extension EnvironmentExtractor {
    public static func data(
        _ key: EnvironmentExtractableKey,
        replacer: EnvironmentReplacer = .init()
    ) throws -> Data {
        let path_value = try value(key, replacer: replacer)
        let url = path_value.path_url()
        return try Data(contentsOf: url)
    }

    public static func base64_data(
        _ key: EnvironmentExtractableKey,
        replacer: EnvironmentReplacer = .init()
    ) throws -> Data {
        return try data(key, replacer: replacer).base64EncodedData()
    }

    public static func base64_string(
        _ key: EnvironmentExtractableKey,
        replacer: EnvironmentReplacer = .init()
    ) throws -> String {
        return try data(key, replacer: replacer).base64EncodedString()
    }
}

extension EnvironmentExtractor {
    private static func mimeType(from url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "png":  return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "svg":  return "image/svg+xml"
        case "webp": return "image/webp"
        default:     return "application/octet-stream"
        }
    }

    public static func base64_html_src(
        _ key: EnvironmentExtractableKey,
        replacer: EnvironmentReplacer = .init()
    ) throws -> String {
        let url = try value(key, replacer: replacer).path_url()
        let mime = mimeType(from: url)
        let base64 = try base64_string(key, replacer: replacer)

        return "data:\(mime);base64,\(base64)"
    }
}
