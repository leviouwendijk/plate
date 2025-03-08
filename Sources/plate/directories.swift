import Foundation

// public enum ReturnType {
//     case url, string
// }

public struct Directories {
    public struct Home {
        public init() {}

        public func url() -> URL {
            return FileManager.default.homeDirectoryForCurrentUser
        }

        public func string() -> String {
            return "\(FileManager.default.homeDirectoryForCurrentUser)"
        }
    }
}
