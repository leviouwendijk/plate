import Foundation

public enum ExecutableObjectType: String, RawRepresentable, Codable {
    case binary
    case application
    case script
}

public enum ObjectVersionLevel: String, RawRepresentable, Codable {
    case major
    case minor
    case patch
}

public struct ObjectVersion: Codable {
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
}

// for local repository build info: object.pkl 
public struct BuildObjectConfiguration: Codable {
    public let uuid: UUID
    public let name: String
    public let type: ExecutableObjectType
    public let version: ObjectVersion
    public let details: String

    public init(uuid: UUID = UUID(), name: String, type: ExecutableObjectType, version: ObjectVersion, details: String) {
        self.uuid = uuid
        self.name = name
        self.type = type
        self.version = version
        self.details = details
    }
}

public struct BuildObjectDetails: Codable {
    public let uuid: UUID
    public let name: String
    public let version: ObjectVersion
    public let details: String
    public let location: String
    public let date: Date

    public init(uuid: UUID, name: String, version: ObjectVersion, details: String, location: String, date: Date) {
        self.uuid = uuid
        self.name = name
        self.version = version
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
