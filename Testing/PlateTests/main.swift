import Foundation
import plate

private enum RegressionFailure: Error {
    case failed(String)
}

private func check(_ condition: @autoclosure () -> Bool, _ name: String) throws {
    guard condition() else { throw RegressionFailure.failed(name) }
    print("PASS \(name)")
}

private func rejects(_ name: String, _ body: () throws -> Void) throws {
    do {
        try body()
        throw RegressionFailure.failed("\(name) unexpectedly accepted")
    } catch is PklParserError {
        print("PASS \(name)")
    }
}

private func run() throws {
    guard let uuid = UUID(uuidString: "2D45ED1F-3F26-4C11-93D1-BB92E9C1A734") else {
        throw RegressionFailure.failed("invalid fixture UUID")
    }
    let config = BuildObjectConfiguration(
        uuid: uuid,
        name: "demo",
        types: [.binary, .script],
        versions: .init(release: .init(major: 1, minor: 2, patch: 3)),
        compile: .init(use: true, arguments: ["-c", "debug"]),
        details: "a test", author: "author", update: "manual"
    )
    let modern_text = config.string()
    let modern_parser = PklParser(modern_text)
    let modern = try modern_parser.parseBuildObject()
    try check(modern.name == "demo" && modern.uuid == uuid, "modern identity")
    try check(Set(modern.types.map(\.rawValue)) == Set(["binary", "script"]), "modern types")
    try check(modern.versions.release.patch == 3, "modern version")
    try check(modern.compile.use && modern.compile.arguments == ["-c", "debug"], "modern compile")
    try check(modern_parser.idx == modern_parser.input.endIndex, "modern parser advances to EOF")

    let legacy_text = """
    // legacy build-object
    uuid = "2D45ED1F-3F26-4C11-93D1-BB92E9C1A734"
    name = "old"
    type = "binary"
    version { major = 2 minor = 0 patch = 5 }
    details = "legacy"
    author = "author"
    update = "manual"
    """
    let legacy_parser = PklParser(legacy_text)
    let legacy = try legacy_parser.parseLegacyBuildObject()
    try check(legacy.name == "old" && legacy.version.patch == 5, "legacy parsing")
    try check(legacy.modernize().types == [.binary], "legacy modernization")
    try check(legacy_parser.idx == legacy_parser.input.endIndex, "legacy parser advances to EOF")

    let compiled = CompiledLocalBuildObject(
        version: .init(major: 4, minor: 3, patch: 2),
        arguments: ["-O", "-g"]
    )
    let compiled_parser = PklParser(compiled.string())
    let roundtripped = try compiled_parser.parseCompiledBuildObject()
    try check(roundtripped.version.major == 4 && roundtripped.arguments == ["-O", "-g"], "compiled round trip")

    let basic = """
    uuid = "2D45ED1F-3F26-4C11-93D1-BB92E9C1A734"
    name = "basic"
    types { "binary" }
    versions { release { major = 0 minor = 1 patch = 0 } }
    details = ""
    author = ""
    update = ""
    """
    let fallback = try PklParser(basic).parseBuildObject()
    try check(!fallback.compile.use && fallback.compile.arguments.isEmpty, "compile fallback")
    let numeric = try PklParser(basic + "\ncompile { use = 2 arguments {} }").parseBuildObject()
    try check(numeric.compile.use && numeric.compile.arguments.isEmpty, "numeric use and empty list")
    let duplicate = try PklParser(basic + "\nname = \"override\"").parseBuildObject()
    try check(duplicate.name == "override", "last duplicate wins")

    try rejects("missing required UUID") {
        _ = try PklParser(basic.replacingOccurrences(of: "uuid = \"2D45ED1F-3F26-4C11-93D1-BB92E9C1A734\"", with: "")).parseBuildObject()
    }
    try rejects("invalid UUID") {
        _ = try PklParser(basic.replacingOccurrences(of: "2D45ED1F-3F26-4C11-93D1-BB92E9C1A734", with: "bad")).parseBuildObject()
    }
    try rejects("invalid types") {
        _ = try PklParser(basic.replacingOccurrences(of: "types { \"binary\" }", with: "types { 3 }")).parseBuildObject()
    }
    try rejects("missing release") {
        _ = try PklParser(basic.replacingOccurrences(of: "release { major = 0 minor = 1 patch = 0 }", with: "")).parseBuildObject()
    }
    try rejects("malformed syntax") {
        _ = try PklParser("name = \"unterminated").parseBuildObject()
    }
}

do {
    try run()
    print("plate Pkl compatibility checks passed")
} catch {
    print("FAIL plate Pkl compatibility: \(error)")
    exit(1)
}
