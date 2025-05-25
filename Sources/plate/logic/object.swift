import Foundation

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

    public func string() -> String {
        return "\(self.major).\(self.minor).\(self.patch)"
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

    public init(from url: URL = URL(fileURLWithPath: "build-object.pkl")) throws {
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
