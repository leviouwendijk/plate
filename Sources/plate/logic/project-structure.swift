import Foundation

public enum ProjectError: Error, LocalizedError {
    case noPathStoredForKey(String)
    case assumedTargetDoesNotExist(String)

    public var errorDescription: String? {
        switch self {
        case .noPathStoredForKey(let key):
            return "No path has been stored for the key '\(key)'. Check your project structure configuration."
        case .assumedTargetDoesNotExist(let path):
            return "The assumed target at path '\(path)' does not exist. Verify the file or directory is present."
        }
    }

    public var failureReason: String? {
        switch self {
        case .noPathStoredForKey:
            return "The requested key could not be matched in the configured project paths."
        case .assumedTargetDoesNotExist:
            return "FileManager could not find any file or directory at the specified location."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .noPathStoredForKey:
            return "Ensure the key is registered in your ProjectStructure paths dictionary."
        case .assumedTargetDoesNotExist:
            return "Ensure the target file or directory exists, or correct the name in your code."
        }
    }

    public var helpAnchor: String? {
        switch self {
        case .noPathStoredForKey:
            return "project.paths.configuration"
        case .assumedTargetDoesNotExist:
            return "filesystem.target.validation"
        }
    }
}

public enum ProjectPathSegmentType: String, RawRepresentable, Sendable {
    case directory
    case file

    public static func from(_ is_dir_obj_c: ObjCBool) -> ProjectPathSegmentType {
        return  is_dir_obj_c.boolValue ? .directory : .file
    }
}

public struct PathExistence: Sendable {
    public static func check(url: URL) -> (Bool, ProjectPathSegmentType?) {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        let type = exists ? ProjectPathSegmentType.from(isDirectory) : nil

        return (exists, type)
    }

    public static func string(result: (Bool, ProjectPathSegmentType?)) -> String {
        var resp = ""
        if result.0 {
            if let type = result.1 {
                resp = "This \(type.rawValue) exists"
            } else {
                resp = "This path exists"
            }
        } else {
            resp = "This path does not exist"
        }
        return resp
    }
}

public protocol ProjectSegmentable: Sendable {
    var value: String { get set }
    var type: ProjectPathSegmentType? { get set }
}

public struct ProjectPathSegment: ProjectSegmentable {
    public var value: String
    public var type: ProjectPathSegmentType?
    
    public init(
        value: String,
        type: ProjectPathSegmentType?
    ) {
        self.value = value
        self.type = type
    }
}

public struct ProjectPath: Sendable {
    public let segments: [ProjectPathSegment]
    
    public init(
        segments: [ProjectPathSegment]
    ) {
        self.segments = segments
    }

    public var concatenated: String {
        segments.map { $0.value }
        .joined(separator: "/")
    }
}

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
