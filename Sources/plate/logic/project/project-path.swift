import Foundation

public protocol SegmentConcatenable: Sendable, Codable {
    var segments: [ProjectPathSegment] { get set }
    var concatenated: String { get }
    func rendered(asRootPath: Bool) -> String
}

extension String {
    public var removed_double_slashes: String {
        return self.replacingOccurrences(of: "//", with: "/")
    }
}

extension SegmentConcatenable {
    public var concatenated: String {
        segments.map { $0.value }
        .joined(separator: "/")
    }

    public func url(base: URL) -> URL {
        var res = base
        for i in segments {
            res = res.appendingPathComponent(i.value)
        }
        return res
    }

    public func rendered(asRootPath: Bool) -> String {
        let concat = self.concatenated
        let prefixed = asRootPath ? "/" + concat : concat
        return prefixed.removed_double_slashes
    }
}

public struct ProjectPath: SegmentConcatenable {
    public var segments: [ProjectPathSegment]
    
    public init(
        segments: [ProjectPathSegment]
    ) {
        self.segments = segments
    }

    public init(
        _ segments: [ProjectPathSegment]
    ) {
        self.segments = segments
    }

    public init(
        _ segments: [String]
    ) {
        self.segments = segments.map( { .init(value: $0, type: nil) } )
    }

    public init(
        _ segments: String...
    ) {
        self.segments = segments.map( { .init(value: $0, type: nil) } )
    }

    public mutating func appendingSegments(_ segments: [ProjectPathSegment]) -> Void {
        for s in segments {
            self.segments.append(s)
        }
    }

    public mutating func appendingSegments(_ strings: [String]) -> Void {
        let typed = strings.map { $0.pathSegment() }
        appendingSegments(typed)
    }

    public mutating func appendingSegments(_ strings: String...) -> Void {
        appendingSegments(strings)
    }
}
