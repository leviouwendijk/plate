import Foundation

public protocol SegmentConcatenable: Sendable, Codable {
    var segments: [ProjectPathSegment] { get set }
    var concatenated: String { get }
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
}

public struct ProjectPath: SegmentConcatenable {
    public var segments: [ProjectPathSegment]
    
    public init(
        segments: [ProjectPathSegment]
    ) {
        self.segments = segments
    }
}

public typealias GenericPath = ProjectPath
