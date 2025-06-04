import Foundation

public enum VersionPrefixStyle {
    case short
    case long
    case none

    public func prefix() -> String {
        switch self {
            case .short:
                return "v"
            case .long:
                return "version"
            case .none:
                return ""
        }
    }
}

public enum ExecutableObjectType: String, RawRepresentable, Codable, Sendable {
    case binary
    case application
    case script
}

public enum ObjectVersionLevel: String, RawRepresentable, Codable, CaseIterable, Sendable {
    case major
    case minor
    case patch
}

public struct ObjectVersion: Codable, Comparable, Sendable {
    public var major: Int
    public var minor: Int
    public var patch: Int

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public func string(prefixStyle: VersionPrefixStyle = .long, remote: Bool = false) -> String {
        let versionPrefix = prefixStyle.prefix()
        var str = ""
        if remote {
            str.append("latest")
            str.append(" ")
        }
        if !(prefixStyle == .none) {
            str.append(versionPrefix)
            str.append(" ")
        }
        str.append("\(self.major).\(self.minor).\(self.patch)")
        return str
    }

    public mutating func increment(_ type: ObjectVersionLevel) {
        switch type {
        case .major:
            major += 1
            minor = 0
            patch = 0
        case .minor:
            minor += 1
            patch = 0
        case .patch:
            patch += 1
        }
    }

    public static func < (lhs: ObjectVersion, rhs: ObjectVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
}

enum TraverseError: Error, LocalizedError {
    case fileNotFound(buildFile: String, maxDepth: Int, startURL: URL)
    
    var errorDescription: String? {
        switch self {
        case let .fileNotFound(buildFile, maxDepth, startURL):
            return "Could not find '\(buildFile)' within \(maxDepth) levels starting at \(startURL.path)"
        }
    }
}

// for local repository build info: object.pkl 
public struct BuildObjectConfiguration: Codable, Sendable {
    public let uuid: UUID
    public let name: String
    public let type: ExecutableObjectType
    public let version: ObjectVersion
    public let details: String
    public let author: String
    public let update: String

    public init(uuid: UUID = UUID(), name: String, type: ExecutableObjectType, version: ObjectVersion, details: String, author: String, update: String) {
        self.uuid = uuid
        self.name = name
        self.type = type
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

    // public func versionString() -> String {
    //     return version.string()
    // }

    // public func appAndVersionString() -> String {
    //     return "\(name) \(version.major).\(version.minor).\(version.patch)"
    // }
}

public struct BuildObjectDetails: Codable {
    public let uuid: UUID
    public let name: String
    public let version: ObjectVersion
    public let latest: ObjectVersion
    public let details: String
    public let location: String
    public let date: Date

    public init(uuid: UUID, name: String, version: ObjectVersion, latest: ObjectVersion, details: String, location: String, date: Date) {
        self.uuid = uuid
        self.name = name
        self.version = version
        self.latest = latest
        self.details = details
        self.location = location
        self.date = date
    }
}

// for the .pkl file in the bm/index.pkl
public struct BuildObjectList: Codable {
    public let type: ExecutableObjectType
    public var objects: [BuildObjectDetails]

    public init(type: ExecutableObjectType, objects: [BuildObjectDetails]) {
        self.type = type
        self.objects = objects
    }
}


