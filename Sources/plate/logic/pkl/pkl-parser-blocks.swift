import Foundation

extension PklParser {
    // public func parseVersionBlock() throws -> ObjectVersion {
    //     let dict = try parseBlock()
    //     guard
    //         let maj = dict["major"] as? Int,
    //         let min = dict["minor"] as? Int,
    //         let pat = dict["patch"] as? Int
    //     else {
    //         throw PklParserError.syntaxError("version block missing major/minor/patch")
    //     }
    //     return ObjectVersion(major: maj, minor: min, patch: pat)
    // }

    public func parseVersionBlock() throws -> ObjectVersion {
        try expect("{")
        var maj: Int?, min: Int?, pat: Int?

        while true {
            skipWhitespaceAndNewlines()
            if idx < input.endIndex, input[idx] == "}" {
                idx = input.index(after: idx); break
            }
            let k = try parseIdentifier()
            try expect("=")
            skipWhitespaceAndNewlines()
            let n = try parseNumber()
            switch k {
            case "major": maj = n
            case "minor": min = n
            case "patch": pat = n
            default:
                throw PklParserError.syntaxError("Unknown key '\(k)' in version block at pos \(position)")
            }
        }

        guard let a = maj, let b = min, let c = pat else {
            throw PklParserError.syntaxError("version block missing major/minor/patch")
        }
        return ObjectVersion(major: a, minor: b, patch: c)
    }

    public func parseVersions() throws -> ProjectVersions {
        // expects:
        // versions { built { ... } repository { ... } }
        try expect("{")
        var built: ObjectVersion?
        var repo:  ObjectVersion?

        while true {
            skipWhitespaceAndNewlines()
            // end of `versions { ... }`
            if idx < input.endIndex, input[idx] == "}" {
                idx = input.index(after: idx)
                break
            }
            let sub = try parseIdentifier() // "built" or "repository"
            skipWhitespaceAndNewlines()
            // sub-block (no '=' here)
            try expect("{")

            // Rewind 1 to pass '{' to parseBlock()
            idx = input.index(before: idx)
            let ver = try parseVersionBlock()

            switch sub {
            case "built":       built = ver
            case "repository":  repo  = ver
            default:
                throw PklParserError.syntaxError("Unknown versions subsection '\(sub)' at pos \(position)")
            }
        }

        guard let b = built, let r = repo else {
            throw PklParserError.syntaxError("versions block must contain both 'built' and 'repository'")
        }
        return ProjectVersions(built: b, repository: r)
    }

    public func parseCompile() throws -> CompileInstructionDefaults {
        try expect("{")
        var use: Bool?
        var args: [String] = []

        while true {
            skipWhitespaceAndNewlines()
            if idx < input.endIndex, input[idx] == "}" {
                idx = input.index(after: idx)
                break
            }
            let key = try parseIdentifier()
            skipWhitespaceAndNewlines()

            if key == "arguments" {
                // arguments { "sbm" "--targets" "disk-map" }
                try expect("{")
                var out: [String] = []
                while true {
                    skipWhitespaceAndNewlines()
                    if idx < input.endIndex, input[idx] == "}" {
                        idx = input.index(after: idx); break
                    }
                    guard idx < input.endIndex, input[idx] == "\"" else {
                        let found = idx < input.endIndex ? String(input[idx]) : "EOF"
                        throw PklParserError.syntaxError("Expected string literal in arguments at pos \(position), found '\(found)'")
                    }
                    out.append(try parseString())
                    skipWhitespaceAndNewlines()
                    if idx < input.endIndex, input[idx] == "," { idx = input.index(after: idx) }
                }
                args = out
            } else {
                // use = true|false
                try expect("=")
                // support 0/1 as numbers too, just in case
                if idx < input.endIndex, input[idx].isNumber {
                    let n = try parseNumber()
                    use = (n != 0)
                } else {
                    let ident = try parseIdentifier() // true/false as bare identifiers
                    switch ident {
                    case "true":  use = true
                    case "false": use = false
                    default:
                        throw PklParserError.invalidValue(field: "use", value: ident)
                    }
                }
            }
        }

        return .init(use: use ?? false, arguments: args)
    }
}
