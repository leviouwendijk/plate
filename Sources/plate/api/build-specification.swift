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

    public func appAndVersionString() -> String {
        return "\(name) \(version.major).\(version.minor).\(version.patch)"
    }

    public init(fromPkl url: URL = URL(fileURLWithPath: "build-object.pkl")) throws {
        let cfg = try BuildObjectConfiguration.parse(from: url)

        // Map into our spec
        self.version = BuildVersion(
            major: cfg.version.major,
            minor: cfg.version.minor,
            patch: cfg.version.patch
        )
        self.name = cfg.name
        self.author = cfg.author
        self.description = cfg.details
    }
}
