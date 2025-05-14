import Foundation

// public enum ReturnType {
//     case url, string
// }

public struct Home {
    public init() {}

    public static func url() -> URL {
        return FileManager.default.homeDirectoryForCurrentUser
    }

    public static func string() -> String {
        return FileManager.default.homeDirectoryForCurrentUser.path
    }
}

public struct User {
    public init() {}

    public static func string() -> String {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/whoami")
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
        } catch {
            print("Error getting current user: \(error)")
            return ""
        }
    }
}
