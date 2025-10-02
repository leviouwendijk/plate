import Foundation

public enum ProjectPathSegmentType: Sendable {
    case directory
    case file
}

public protocol ProjectSegmentable: Sendable {
    var value: String { get set }
    var type: ProjectPathSegmentType { get set }
}

public struct ProjectPathSegment: ProjectSegmentable {
    public var value: String
    public var type: ProjectPathSegmentType
    
    public init(
        value: String,
        type: ProjectPathSegmentType
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

public enum ProjectError: Error, LocalizedError {
    case noPathStoredForKey(String)
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

    // public enum Place: Sendable {
    //     case in_dictionary
    //     case on_disk
    // }

    // public func exists(for key: String, in place: Place) throws -> (Bool, String) {
    public func exists(for key: String) throws -> Bool {
        let url = try path(for: key)
        return FileManager.default.fileExists(atPath: url.path)
    }

    public func read(for key: String) throws -> [String: String] {
        return paths.mapValues { $0.concatenated }
    }
}
