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

    public struct StringOptions: Codable, Sendable {
        public struct Remote: Codable, Sendable {
            var include: Bool
            var label: String
            
            public init(
                include: Bool = false,
                label: String = "latest"
            ) {
                self.include = include
                self.label = label
            }
        }

        public struct Prefix: Codable, Sendable {
            var style: VersionPrefixStyle
            var separator: String?
            
            public init(
                style: VersionPrefixStyle = .long,
                separator: String? = " "
            ) {
                self.style = style
                self.separator = separator
            }
        }

        public struct Version: Codable, Sendable {
            var separator: String?
            
            public init(
                separator: String? = "."
            ) {
                self.separator = separator
            }
        }

        var remote: Remote
        var prefix: Prefix
        var version: Version
        
        public init(
            remote: Remote = Remote(),
            prefix: Prefix = Prefix(),
            version: Version = Version()
        ) {
            self.remote = remote
            self.prefix = prefix
            self.version = version
        }
    }

    public func string(
        options: StringOptions = StringOptions()
    ) -> String {
        let versionPrefix = options.prefix.style.prefix()

        var str: [String] = []

        if options.remote.include {
            str.append(options.remote.label)
        }

        // var version_comps: [String] = []
        // if !(options.prefix.style == .none) {
        //     version_comps.append(versionPrefix)
        // }

        var numerics: [String] = []
        numerics.append("\(self.major)")
        numerics.append("\(self.minor)")
        numerics.append("\(self.patch)")

        let nums: String
        if let v_sep = options.version.separator {
            nums = numerics.joined(separator: v_sep)
        } else {
            nums = numerics.joined()
        }

        // version_comps.append(nums)

        let version: String
        if !(options.prefix.style == .none) {
            var version_comps: [String] = []
            version_comps.append(versionPrefix)
            version_comps.append(nums)
            if let p_sep = options.prefix.separator {
                version = version_comps.joined(separator: p_sep)
            } else {
                version = version_comps.joined()
            }
        } else {
            version = nums
        }

        str.append(version)

        return str.joined(separator: " ")
    }

    public func string(
        prefixStyle: VersionPrefixStyle = .long,
        remote: Bool = false,
        prefixSpace: Bool = true
    ) -> String {
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
