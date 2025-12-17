import Foundation
import Version

extension PklParser {
    public func parseCompiledBuildObject() throws -> CompiledLocalBuildObject {
        var version: ObjectVersion?
        var arguments: [String]?

        while skipWhitespaceAndNewlines() {
            let key = try parseIdentifier()
            skipWhitespaceAndNewlines()
            if key == "compiled" {
                try expect("{")
                skipWhitespaceAndNewlines()

                let nestedKey = try parseIdentifier()
                if nestedKey != "version" {
                    throw PklParserError.syntaxError("Expected 'version' at \(position), found: \(nestedKey)") 
                }

                version = try parseVersionBlock()

                let args = try parseIdentifier()
                if args == "arguments" {
                    arguments = try parseStringListBlock()
                }

                try expect("}")
            } else {
                throw PklParserError.syntaxError("Expected 'compiled' at \(position), found: \(key)")
            }
        }

        guard let ver = version else { throw PklParserError.missingField("version") }
        guard let args = arguments else { throw PklParserError.missingField("arguments") }

        return CompiledLocalBuildObject(
            version: ver,
            arguments: args
        )
    }
}
