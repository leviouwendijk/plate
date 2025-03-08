import Foundation

// public enum ReturnType {
//     case url, string
// }

public struct Directories {
    public struct Home {
        public func asURL() -> URL {
            return FileManager.default.homeDirectoryForCurrentUser
        }

        public func asString() -> String {
            return "\(FileManager.default.homeDirectoryForCurrentUser)"
        }
    }
}
