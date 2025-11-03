import Foundation

public struct GenericEntryPoint {
    public let registered_arguments: [ProcessableGenericArgument]
    public var provided_arguments: [String]
    public let entry_point: String

    public init(
        with registered_arguments: [ProcessableGenericArgument] = []
    ) { 
        self.registered_arguments = registered_arguments
        self.provided_arguments = CommandLine.arguments
        // self.entry_point = provided_arguments[0]
        // provided_arguments.remove(at: 0)
        self.entry_point = provided_arguments.first ?? "no_entry_point_found"
        if !provided_arguments.isEmpty { provided_arguments.removeFirst() }
    }

    @discardableResult
    public func process_entry() throws -> [String] {
        try process_args()
    }

    private func process_args() throws -> [String] {
        guard !registered_arguments.isEmpty else {
            throw GenericArgumentError.noGenericArgumentsRegisteredAtRuntime
        }

        var lookup: [String: ProcessableGenericArgument] = [:]
        for spec in registered_arguments {
            for alias in spec.aliases { lookup[alias.identifier] = spec }
        }

        var positionals: [String] = []
        let argv = provided_arguments
        var i = 0
        var stopParsing = false

        while i < argv.count {
            let tok = argv[i]

            if stopParsing || !tok.hasPrefix("-") || tok == "-" {
                positionals.append(tok); i += 1; continue
            }

            if tok == "--" {
                stopParsing = true; i += 1; continue
            }

            // Long: --opt or --opt=val
            if tok.hasPrefix("--") {
                if let eq = tok.firstIndex(of: "=") {
                    let flag = String(tok[..<eq])
                    let val  = String(tok[tok.index(after: eq)...])
                    guard let spec = lookup[flag] else { throw GenericArgumentError.unrecognizedGenericArgument(tok, i+1) }
                    switch spec.kind {
                    case .flag: throw GenericArgumentError.invalidCombination(tok)
                    case let .option(action): action(val)
                    case let .optionalOption(action): action(val)
                    }
                    i += 1
                } else {
                    guard let spec = lookup[tok] else { throw GenericArgumentError.unrecognizedGenericArgument(tok, i+1) }
                    switch spec.kind {
                    case let .flag(action):
                        action(); i += 1
                    case let .option(action):
                        let ni = i + 1
                        guard ni < argv.count else { throw GenericArgumentError.missingValue(forFlag: tok) }
                        action(argv[ni]); i += 2
                    case let .optionalOption(action):
                        let ni = i + 1
                        if ni < argv.count, !argv[ni].hasPrefix("-") {
                            action(argv[ni]); i += 2
                        } else {
                            action(nil); i += 1
                        }
                    }
                }
                continue
            }

            // Short(s): -a, -abc, -oVal, -o Val
            let cluster = String(tok.dropFirst())

            // Single short like "-o" or "-v"
            if cluster.count == 1 {
                let ident = "-\(cluster)"
                guard let spec = lookup[ident] else { throw GenericArgumentError.unrecognizedGenericArgument(tok, i+1) }
                switch spec.kind {
                case let .flag(action):
                    action(); i += 1
                case let .option(action):
                    let ni = i + 1
                    guard ni < argv.count else { throw GenericArgumentError.missingValue(forFlag: ident) }
                    action(argv[ni]); i += 2
                case let .optionalOption(action):
                    let ni = i + 1
                    if ni < argv.count, !argv[ni].hasPrefix("-") {
                        action(argv[ni]); i += 2
                    } else {
                        action(nil); i += 1
                    }
                }
                continue
            }

            // Multi-char cluster: "-abc" or "-oVal"
            let first = String(cluster.prefix(1))
            let rest  = String(cluster.dropFirst())
            let firstIdent = "-\(first)"
            guard let spec = lookup[firstIdent] else { throw GenericArgumentError.unrecognizedGenericArgument(tok, i+1) }

            switch spec.kind {
            case let .flag(action):
                action()
                // Remaining chars must all be flags
                for ch in rest {
                    let ident = "-\(ch)"
                    guard let s2 = lookup[ident] else { throw GenericArgumentError.unrecognizedGenericArgument("-\(cluster)", i+1) }
                    switch s2.kind {
                    case let .flag(a2): a2()
                    case .option, .optionalOption:
                        throw GenericArgumentError.invalidCombination("-\(cluster)")
                    }
                }
                i += 1

            case let .option(action):
                if rest.isEmpty {
                    let ni = i + 1
                    guard ni < argv.count else { throw GenericArgumentError.missingValue(forFlag: firstIdent) }
                    action(argv[ni]); i += 2
                } else {
                    action(rest); i += 1
                }

            case let .optionalOption(action):
                if rest.isEmpty {
                    let ni = i + 1
                    if ni < argv.count, !argv[ni].hasPrefix("-") {
                        action(argv[ni]); i += 2
                    } else {
                        action(nil); i += 1
                    }
                } else {
                    action(rest); i += 1
                }
            }
        }
        return positionals
    }
}
