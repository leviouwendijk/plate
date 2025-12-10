import Foundation

public protocol EnvironmentReplacing: Sendable {
    var replacements: [EnvironmentReplacement] { get }
    var policy: EnvironmentExpansionPolicy { get }
}

public enum EnvironmentReplacementValue: Sendable, Equatable {
    case value(String)                       
    case env(String)                         
    case home                       
    case cwd                    
}

/// A single explicit replacement rule.
/// Examples:
///     .variable(key: "$THIS", replacement: .value("asdf"))
///     .variable(key: "$HOME", replacement: .home)
///     .variable(key: "$CWD", replacement: .cwd)
public enum EnvironmentReplacement: Sendable, Equatable {
    case variable(key: String, replacement: EnvironmentReplacementValue)

    static let home = Self.variable(key: "$HOME", replacement: .home)
    static let cwd = Self.variable(key: "$CWD", replacement: .cwd)
}

/// How to combine explicit replacements with other sources.
public enum EnvironmentExpansionPolicy: Sendable, Equatable {
    /// Only use explicit `.replacements`; unknown tokens are left *as-is* (no fallback).
    case strict
    /// Use `.replacements` first, then fallback to provided dictionary (e.g. file vars), then process env.
    case permissive(fileEnv: [String: String] = [:], processEnv: [String: String] = ProcessInfo.processInfo.environment)
}

public struct EnvironmentReplacer: EnvironmentReplacing, Equatable {
    public var replacements: [EnvironmentReplacement]
    public var policy: EnvironmentExpansionPolicy

    public init(
        replacements: [EnvironmentReplacement] = [],
        policy: EnvironmentExpansionPolicy = .strict,
    ) {
        self.replacements = replacements
        self.policy = policy
    }

    @inline(__always)
    private func resolve(_ replacement: EnvironmentReplacementValue) -> String? {
        switch replacement {
        case .value(let s): return s
        case .env(let name): return ProcessInfo.processInfo.environment[name]
        case .home: return FileManager.default.homeDirectoryForCurrentUser.path
        case .cwd: return FileManager.default.currentDirectoryPath
        }
    }

    public func apply(to resolvedValue: String) -> String {
        var out = resolvedValue
        for r in replacements {
            guard
                case
                    let .variable(key, repl) = r,
                    let val = resolve(repl)
            else {
                continue
            }
            if !key.isEmpty {
                out = out.replacingOccurrences(of: key, with: val)
            }
        }

        switch policy {
        case .strict:
            return out

        case .permissive(let fileEnv, let procEnv):
            var tmp = out
            for (k, v) in procEnv {
                tmp = tmp.replacingOccurrences(of: "$" + k, with: v)
            }
            for (k, v) in fileEnv {
                tmp = tmp.replacingOccurrences(of: "$" + k, with: v)
            }
            return tmp
        }
    }
}
