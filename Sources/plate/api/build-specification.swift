import Foundation

public struct BuildVersion {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(
        major: Int,
        minor: Int,
        patch: Int
    ) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

public struct BuildSpecification {
    public let version: BuildVersion
    public let name: String
    public let author: String
    public let description: String

    public init(
        version: BuildVersion,
        name: String,
        author: String = "",
        description: String = ""
    ) {
        self.version = version
        self.name = name
        self.author = author
        self.description = description
    }

    public func versionString() -> String {
        return "\(version.major).\(version.minor).\(version.patch)"
    }
}
