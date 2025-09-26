import Foundation

extension CompiledLocalBuildObject {
    public func string() -> String {
        var args: String {
            return arguments
            .map { String(reflecting: $0).indent() }
            .joined(separator: " ")
        }

        let pklContent = """
        compiled {
            version {
                major = \(version.major)
                minor = \(version.minor)
                patch = \(version.patch)
            }
        }
        arguments { \(args) }
        """

        return pklContent
    }

    public func write(to url: URL) throws -> Void {
        let path = url.path
        let string = string()
        do {
            try string.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            throw PklParserError.ioError(
                "Failed to write PKL to '\(path)': \(error.localizedDescription)"
            )
        }
    }
}
