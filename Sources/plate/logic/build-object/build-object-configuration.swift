import Foundation

enum TraverseError: Error, LocalizedError {
    case fileNotFound(buildFile: String, maxDepth: Int, startURL: URL)
    
    var errorDescription: String? {
        switch self {
        case let .fileNotFound(buildFile, maxDepth, startURL):
            return "Could not find '\(buildFile)' within \(maxDepth) levels starting at \(startURL.path)"
        }
    }
}

// for local repository build info: build-object.pkl 
public struct BuildObjectConfiguration: Codable, Sendable {
    public let uuid: UUID
    public let name: String
    public let types: [ExecutableObjectType]
    public let version: ObjectVersion
    public let details: String
    public let author: String
    public let update: String

    public init(uuid: UUID = UUID(), name: String, types: [ExecutableObjectType], version: ObjectVersion, details: String, author: String, update: String) {
        self.uuid = uuid
        self.name = name
        self.types = types
        self.version = version
        self.details = details
        self.author = author
        self.update = update
    }

    public init(from url: URL) throws {
        self = try BuildObjectConfiguration.parse(from: url)
    }

    public init(traversingFor buildFile: String = "build-object.pkl", maxDepth: Int = 5) throws {
        let url = try BuildObjectConfiguration.traverseForBuildObjectPkl(buildFile: buildFile)
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

    public static func traverseForBuildObjectPkl(
        from startURL: URL = Bundle.main.bundleURL,
        maxDepth: Int = 5,
        buildFile: String = "build-object.pkl"
    ) throws -> URL {
        var url = startURL
        let fm = FileManager.default
        var depth = 0

        while depth < maxDepth {
            let candidate = url.appendingPathComponent(buildFile)
            if fm.fileExists(atPath: candidate.path) {
                return candidate
            }
            let parent = url.deletingLastPathComponent()
            guard parent.path != url.path else { break }
            url = parent
            depth += 1
        }

        throw TraverseError.fileNotFound(
            buildFile: buildFile,
            maxDepth: maxDepth,
            startURL: startURL
        )
    }
}
