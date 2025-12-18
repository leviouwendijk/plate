import Foundation
import Indentation

extension BuildObjectConfiguration {
    public func string() -> String {
        let typesList = types
        .map(\.rawValue)
        .sorted()
        .map { String(reflecting: $0).indent() }
        .joined(separator: "\n")

        let pklContent = """
        uuid = "\(uuid)"
        name = "\(name)"
        types {
        \(typesList)
        }
        versions {
            release {
                major = \(versions.release.major)
                minor = \(versions.release.minor)
                patch = \(versions.release.patch)
            }
        }
        compile {
        \(compile.contents())
        }
        details = "\(details)"
        author = "\(author)"
        update = "\(update)"
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
