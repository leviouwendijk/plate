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
