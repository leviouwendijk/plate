import Foundation

public enum ObjectVersionLevel: String, RawRepresentable, Codable, CaseIterable, Sendable {
    case major
    case minor
    case patch
}

public typealias BuildVersion = ObjectVersion

public struct ObjectVersion: Codable, Comparable, Sendable {
    public var major: Int
    public var minor: Int
    public var patch: Int

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public static func default_version(for reference: VersionReference = .release) -> ObjectVersion {
        switch reference {
        // case .repository:
        //     return .init(
        //         major: 0,
        //         minor: 1,
        //         patch: 0
        //     )
        // case .built:
        //     return .init(
        //         major: 0,
        //         minor: 0,
        //         patch: 0
        //     )
        // }
        case .release:
            return .init(
                major: 0,
                minor: 1,
                patch: 0
            )
        case .compiled:
            return .init(
                major: 0,
                minor: 0,
                patch: 0
            )
        }
    }

    public func string(prefixStyle: VersionPrefixStyle = .long, remote: Bool = false, prefixSpace: Bool = true) -> String {
        let versionPrefix = prefixStyle.prefix()

        var str: [String] = []

        if remote {
            str.append("latest")
        }

        var version_comps: [String] = []
        if !(prefixStyle == .none) {
            version_comps.append(versionPrefix)
        }

        var numerics: [String] = []
        numerics.append("\(self.major)")
        numerics.append("\(self.minor)")
        numerics.append("\(self.patch)")
        let nums = numerics.joined(separator: ".")

        version_comps.append(nums)

        let version = prefixSpace ? version_comps.joined(separator: " ") : version_comps.joined()
        str.append(version)

        return str.joined(separator: " ")
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
