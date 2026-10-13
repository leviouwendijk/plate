import Foundation
import Parsers
import Version

// Build-object semantics belong to plate; the syntax tree belongs to Parsers.
// Keep this internal while callers still use the public PklParser entry points.
enum BuildObjectPklDecoder {
    static func modern(_ document: Pkl.Document) throws -> BuildObjectConfiguration {
        let entries = document.entries
        let uuid = try required_uuid(entries, "uuid")
        let name = try required_string(entries, "name")
        let types = try string_list(try required(entries, "types"))
            .map { text -> ExecutableObjectType in
                guard let value = ExecutableObjectType(rawValue: text) else {
                    throw PklParserError.invalidValue(field: "types", value: text)
                }
                return value
            }
        guard !types.isEmpty else {
            throw PklParserError.missingField("types")
        }

        let versions = try versions(try required(entries, "versions"))
        let compile: CompileInstructionDefaults
        if let entry = last(entries, "compile") {
            compile = try compile_instructions(entry)
        } else {
            compile = .init(use: false, arguments: [])
        }

        return BuildObjectConfiguration(
            uuid: uuid,
            name: name,
            types: types,
            versions: versions,
            compile: compile,
            details: try required_string(entries, "details"),
            author: try required_string(entries, "author"),
            update: try required_string(entries, "update")
        )
    }

    static func legacy(_ document: Pkl.Document) throws -> BuildObjectConfiguration.LegacyObject {
        let entries = document.entries
        let name = try required_string(entries, "type")
        guard let type = ExecutableObjectType(rawValue: name) else {
            throw PklParserError.invalidValue(field: "type", value: name)
        }
        return BuildObjectConfiguration.LegacyObject(
            uuid: try required_uuid(entries, "uuid"),
            name: try required_string(entries, "name"),
            type: type,
            version: try version(try required(entries, "version")),
            details: try required_string(entries, "details"),
            author: try required_string(entries, "author"),
            update: try required_string(entries, "update")
        )
    }

    static func compiled(_ document: Pkl.Document) throws -> CompiledLocalBuildObject {
        let fields = try block(try required(document.entries, "compiled"))
        for entry in fields where entry.name != "version" && entry.name != "arguments" {
            throw PklParserError.syntaxError("Unknown compiled field '\(entry.name)'")
        }
        return CompiledLocalBuildObject(
            version: try version(try required(fields, "version")),
            arguments: try string_list(try required(fields, "arguments"))
        )
    }

    private static func last(_ entries: [Pkl.Entry], _ name: String) -> Pkl.Entry? {
        entries.last { $0.name == name }
    }

    private static func required(_ entries: [Pkl.Entry], _ name: String) throws -> Pkl.Entry {
        guard let entry = last(entries, name) else {
            throw PklParserError.missingField(name)
        }
        return entry
    }

    private static func block(_ entry: Pkl.Entry) throws -> [Pkl.Entry] {
        guard case .block(let fields) = entry.value else {
            throw invalid(entry)
        }
        return fields
    }

    private static func invalid(_ entry: Pkl.Entry) -> PklParserError {
        .invalidValue(field: entry.name, value: String(describing: entry.value))
    }

    private static func required_string(_ entries: [Pkl.Entry], _ name: String) throws -> String {
        let entry = try required(entries, name)
        guard case .string(let value) = entry.value else {
            throw invalid(entry)
        }
        return value
    }

    private static func required_integer(_ entries: [Pkl.Entry], _ name: String) throws -> Int {
        let entry = try required(entries, name)
        guard case .integer(let value) = entry.value else {
            throw invalid(entry)
        }
        return value
    }

    private static func required_uuid(_ entries: [Pkl.Entry], _ name: String) throws -> UUID {
        let text = try required_string(entries, name)
        guard let value = UUID(uuidString: text) else {
            throw PklParserError.invalidValue(field: name, value: text)
        }
        return value
    }

    private static func string_list(_ entry: Pkl.Entry) throws -> [String] {
        let values: [Pkl.Value]
        switch entry.value {
        case .collection(let elements):
            values = elements
        case .block(let entries) where entries.isEmpty:
            // A bare `{}` has no syntax-level distinction between block and collection.
            values = []
        default:
            throw invalid(entry)
        }
        return try values.map { value in
            guard case .string(let text) = value else {
                throw PklParserError.invalidValue(field: entry.name, value: String(describing: value))
            }
            return text
        }
    }

    private static func version(_ entry: Pkl.Entry) throws -> ObjectVersion {
        let fields = try block(entry)
        for field in fields where field.name != "major" && field.name != "minor" && field.name != "patch" {
            throw PklParserError.syntaxError("Unknown key '\(field.name)' in version block")
        }
        guard last(fields, "major") != nil,
              last(fields, "minor") != nil,
              last(fields, "patch") != nil else {
            throw PklParserError.syntaxError("version block missing major/minor/patch")
        }
        return ObjectVersion(
            major: try required_integer(fields, "major"),
            minor: try required_integer(fields, "minor"),
            patch: try required_integer(fields, "patch")
        )
    }

    private static func versions(_ entry: Pkl.Entry) throws -> ProjectVersions {
        let fields = try block(entry)
        for field in fields where field.name != "release" {
            throw PklParserError.syntaxError("Unknown versions subsection '\(field.name)'")
        }
        guard let release = last(fields, "release") else {
            throw PklParserError.missingField("versions.release")
        }
        return ProjectVersions(release: try version(release))
    }

    private static func compile_instructions(_ entry: Pkl.Entry) throws -> CompileInstructionDefaults {
        let fields = try block(entry)
        for field in fields where field.name != "use" && field.name != "arguments" {
            throw PklParserError.syntaxError("Unknown compile field '\(field.name)'")
        }
        var use = false
        if let field = last(fields, "use") {
            switch field.value {
            case .boolean(let enabled):
                use = enabled
            case .integer(let number):
                use = number != 0
            default:
                throw invalid(field)
            }
        }
        let args: [String]
        if let field = last(fields, "arguments") {
            args = try string_list(field)
        } else {
            args = []
        }
        return .init(use: use, arguments: args)
    }
}
