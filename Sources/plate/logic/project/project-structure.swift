import Foundation
import Path

public struct ProjectStructure: Sendable {
    public let root: URL
    public let paths: [String: ProjectPath]
    
    public init(
        root: URL,
        paths: [String: ProjectPath]
    ) {
        self.root = root
        self.paths = paths
    }

    public init(
        root: String,
        paths: [String: ProjectPath]
    ) {
        self.root = URL(fileURLWithPath: root)
        self.paths = paths
    }

    public func append(path: ProjectPath) -> URL {
        var url = root
        for i in path.segments {
            url = url.appendingPathComponent(i.value)
        }
        return url
    }

    public func match(for key: String) throws -> ProjectPath {
        if let match = paths[key] { 
            return match
        } else {
            throw ProjectError.noPathStoredForKey(key)
        }
    }

    public func path(for key: String) throws -> URL {
        let match = try match(for: key)
        let url = append(path: match)
        return url
    }   

    public func subroot(using key: String?) throws -> URL {
        if let k = key {
            let match = try match(for: k)
            return append(path: match)
        } else {
            return root
        }
    }   

    public func locate(subroot key: String?, appending target: String) throws -> URL {
        let subroot = try subroot(using: key)
        let assumedTarget = subroot.appendingPathComponent(target)

        var isDirectory: ObjCBool = false
        let existent = FileManager.default.fileExists(atPath: assumedTarget.path, isDirectory: &isDirectory)

        if existent { 
            return assumedTarget
        } else {
            throw ProjectError.assumedTargetDoesNotExist(assumedTarget.path)
        }
    }   

    public func exists(for key: String) throws -> (Bool, ProjectPathSegmentType?) {
        let url = try path(for: key)
        let (exists, type) = PathExistence.check(url: url)
        return (exists, type)
    }

    public func read(for key: String) throws -> [String: String] {
        return paths.mapValues { $0.concatenated }
    }
}
