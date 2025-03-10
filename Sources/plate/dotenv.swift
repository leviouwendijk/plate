import Foundation

public struct DotEnv {
    private let filePath: String

    public init(traverse: Int = 0, path: String = ".env") {
        var finalPath = ""
        var traversals = traverse

        while traversals > 0 {
            finalPath.append("../")
            traversals -= 1
        }

        finalPath.append(path)
        self.filePath = finalPath
    }

    public func load() throws {
        let fileURL = URL(fileURLWithPath: filePath)

        let contents = try String(contentsOf: fileURL, encoding: .utf8)

        for line in contents.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else {
                continue
            }

            let parts = trimmed.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if parts.count == 2 {
                setenv(parts[0], parts[1], 1)
            }
        }
    }
}

public func environment(_ variable: String) -> String {
    guard let value = ProcessInfo.processInfo.environment[variable] else {
        fatalError("Environment variable \(variable) not found!")
    }
    return value
}
