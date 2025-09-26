import Foundation

// for local repository build info: build-object.pkl 
public struct BuildObjectConfiguration: Codable, Sendable {
    public let uuid: UUID
    public let name: String
    public let types: [ExecutableObjectType]
    public let versions: ProjectVersions
    public let compile: CompileInstructionDefaults
    public let details: String
    public let author: String
    public let update: String

    public init(
        uuid: UUID = UUID(),
        name: String,
        types: [ExecutableObjectType],
        versions: ProjectVersions,
        compile: CompileInstructionDefaults,
        details: String,
        author: String,
        update: String
    ) {
        self.uuid = uuid
        self.name = name
        self.types = types
        self.versions = versions
        self.compile = compile
        self.details = details
        self.author = author
        self.update = update
    }

    public init(from url: URL) throws {
        self = try BuildObjectConfiguration.parse(from: url)
    }

    public init(traversingFor buildFile: String = "build-object.pkl", maxDepth: Int = 5) throws {
        let url = try BuildObjectConfiguration.traverseForBuildObjectPkl(
            maxDepth: maxDepth,
            buildFile: buildFile
        )
        self = try BuildObjectConfiguration.parse(from: url)
    }

    public static func parse(from url: URL) throws -> BuildObjectConfiguration {
        let path = url.path
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            let parser = PklParser(text)
            return try parser.parseBuildObject()
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
