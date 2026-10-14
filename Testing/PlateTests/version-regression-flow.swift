import Testing
import Version

extension PlateTestSuite {
    static let versionRegressionSuite = TestSuite(
        "version",
        title: "Legacy version formatting",
        tags: ["plate", "version", "legacy"]
    ) {
        Test("default, short and unprefixed strings") {
            let version = ObjectVersion(major: 0, minor: 1, patch: 6)
            try Expect.equal(version.string(), "version 0.1.6")
            try Expect.equal(version.string(prefixStyle: .short, prefixSpace: false), "v0.1.6")
            try Expect.equal(version.string(prefixStyle: .none, prefixSpace: false), "0.1.6")
        }
        Test("version string options") {
            let version = ObjectVersion(major: 0, minor: 1, patch: 6)
            try Expect.equal(version.string(options: .init()), "version 0.1.6")
            let options = ObjectVersion.StringOptions(
                remote: .init(include: false),
                prefix: .init(style: .short, separator: "-"),
                version: .init(separator: "-")
            )
            try Expect.equal(version.string(options: options), "v-0-1-6")
        }
    }
}
