import Foundation

public struct Directories {
    public struct Home {
        public func url() -> URL {
            return FileManager.default.homeDirectoryForCurrentUser
        }

        public func string() -> String {
            return "\(FileManager.default.homeDirectoryForCurrentUser)"
        }
    }
}
