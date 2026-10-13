import Testing
import plate

let obj_version = ObjectVersion(
    major: 0,
    minor: 1,
    patch: 6
)

@Test 
func legacy_object_version() async throws {
    let default_str = obj_version.string()
    let short_str = obj_version.string(prefixStyle: .short, prefixSpace: false)
    let no_prefix_str = obj_version.string(prefixStyle: .none, prefixSpace: false)

    #expect(default_str == "version 0.1.6")
    #expect(short_str == "v0.1.6")
    #expect(no_prefix_str == "0.1.6")
}

@Test 
func optioned_object_version() async throws {
    let string_opts = ObjectVersion.StringOptions()
    let obj_version_opts = obj_version.string(options: string_opts)

    let special_opts = ObjectVersion.StringOptions(
        remote: .init(include: false),
        prefix: .init(style: .short, separator: "-"),
        version: .init(separator: "-")
    )
    let obj_version_special_opts = obj_version.string(options: special_opts)

    #expect(obj_version_opts == "version 0.1.6")
    #expect(obj_version_special_opts == "v-0-1-6")
}
