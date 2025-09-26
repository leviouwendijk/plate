import Foundation

extension CompiledLocalBuildObject {
    public static func new(to url: URL) throws {
        let new = empty()
        do {
            try new.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw PklParserError.ioError(
                "Failed to write PKL to '\(url.path)': \(error.localizedDescription)"
            )
        }
    }

    public static func empty() -> String {
        let empty = CompiledLocalBuildObject(
            version: ObjectVersion.default_version(for: .compiled),
            arguments: []
        )
        return empty.string()
    }
}
