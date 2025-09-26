import Foundation

// track which version was built locally (.gitignore)
public struct CompiledLocalBuildObject: Codable, Sendable {
    public let version: ObjectVersion
    public let arguments: [String]

    public init(
        version: ObjectVersion,
        arguments: [String]
    ) {
        self.version = version
        self.arguments = arguments
    }

    public init(from url: URL) throws {
        self = try Self.parse(from: url)
    }

    public init(traversingFor compiledFile: String = "compiled.pkl", maxDepth: Int = 5) throws {
        let url = try Self.traverseForCompiledObjectPkl(
            maxDepth: maxDepth,
            compiledFile: compiledFile
        )
        self = try Self.parse(from: url)
    }

    public static func parse(from url: URL) throws -> CompiledLocalBuildObject {
        let path = url.path
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            let parser = PklParser(text)
            return try parser.parseCompiledBuildObject()
        } catch let err as PklParserError {
            throw PklParserError.syntaxError(
                "Error parsing PKL at '\(path)': \(err.description)"
            )
        } catch {
            throw PklParserError.ioError(
                "Failed to load PKL at '\(path)': \(error.localizedDescription)"
            )
        }
    }
}
