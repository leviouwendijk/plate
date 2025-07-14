import Foundation

public enum PlateDirectoriesError: Error, LocalizedError {
    case cannotCreateURLFromString
}

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

public struct CWD {
    public init() {}

    public static func url() throws -> URL {
        if let url = URL(string: FileManager.default.currentDirectoryPath) {
            return url
        } else {
            throw PlateDirectoriesError.cannotCreateURLFromString
        }
    }

    public static func string() -> String {
        return FileManager.default.currentDirectoryPath
    }

    public static func appending(_ component: String) -> String {
        return self.string() + component
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

public struct DefaultEnvironmentVariables {
    public init() {}

    public static func string() -> String {
        let home = Home.string()
        return "\(home)/dotfiles/.vars.zsh"
    }
}
