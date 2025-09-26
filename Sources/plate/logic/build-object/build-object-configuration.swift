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

public struct CompileInstructionDefaults: Codable, Sendable {
    public let use: Bool // let sbm compile like this as  override or fallback
    public let arguments: [String]
    
    public init(
        use: Bool = false,
        arguments: [String] = []
    ) {
        self.use = use
        self.arguments = arguments
    }

    public var args: String {
        return arguments
        .map { String(reflecting: $0).indent() }
        .joined(separator: " ")
    }

    public func contents() -> String {
        return """
            use = \(use)
            arguments { \(args) }
        """
    }
}

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

extension BuildObjectConfiguration {
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

extension BuildObjectConfiguration {
    public static func new(to url: URL) throws {
        let new = empty()
        do {
            try new.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw PklParserError.ioError(
                "Failed to write PKL to '\(url.path)': \(error.localizedDescription)"
            )
        }
    }

    public static func empty() -> String {
        let empty = BuildObjectConfiguration(
            name: "",
            types: [],
            versions: .init(
                built: ObjectVersion.default_version(for: .built),
                repository: ObjectVersion.default_version(for: .repository)
            ),
            compile: .init(),
            details: "",
            author: "",
            update: ""
        )
        return empty.string()
    }
}

extension BuildObjectConfiguration {
    public func string() -> String {
        let typesList = types
        .map(\.rawValue)
        .sorted()
        .map { String(reflecting: $0).indent() }
        .joined(separator: "\n")

        let pklContent = """
        uuid = "\(uuid)"
        name = "\(name)"
        types {
        \(typesList)
        }
        versions {
            built {
                major = \(versions.built.major)
                minor = \(versions.built.minor)
                patch = \(versions.built.patch)
            }

            repository {
                major = \(versions.repository.major)
                minor = \(versions.repository.minor)
                patch = \(versions.repository.patch)
            }
        }
        compile {
        \(compile.contents())
        }
        details = "\(details)"
        author = "\(author)"
        update = "\(update)"
        """

        return pklContent
    }

    public func write(to url: URL) throws -> Void {
        let path = url.path
        let string = string()
        do {
            try string.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            throw PklParserError.ioError(
                "Failed to write PKL to '\(path)': \(error.localizedDescription)"
            )
        }
    }
}

extension BuildObjectConfiguration {
    public struct LegacyObject: Codable, Sendable {
        public let uuid: UUID
        public let name: String
        public let type: ExecutableObjectType
        public let version: ObjectVersion
        public let details: String
        public let author: String
        public let update: String

        public init(
            uuid: UUID = UUID(),
            name: String,
            type: ExecutableObjectType,
            version: ObjectVersion,
            details: String,
            author: String,
            update: String
        ) {
            self.uuid = uuid
            self.name = name
            self.type = type
            self.version = version
            self.details = details
            self.author = author
            self.update = update
        }

        // turn legacy into modern struct
        public func modernize() -> BuildObjectConfiguration {
            return .init(
                uuid: uuid,
                name: name,
                types: [type],
                versions: ProjectVersions(
                    built: ObjectVersion.default_version(for: .built),
                    repository: version
                ),
                compile: .init(),
                details: details,
                author: author,
                update: update
            )
        }
    }
}
