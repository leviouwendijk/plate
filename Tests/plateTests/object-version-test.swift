import Testing
@testable import plate

@Test 
func objectVersion() async throws {
    let obj_version = ObjectVersion(
        major: 0,
        minor: 1,
        patch: 6
    )

    let default_str = obj_version.string()
    let short_str = obj_version.string(prefixStyle: .short, prefixSpace: false)
    let no_prefix_str = obj_version.string(prefixStyle: .none, prefixSpace: false)

    #expect(default_str == "version 0.1.6")
    #expect(short_str == "v0.1.6")
    #expect(no_prefix_str == "0.1.6")
}
