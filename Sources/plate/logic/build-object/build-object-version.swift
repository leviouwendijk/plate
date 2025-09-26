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

