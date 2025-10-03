import Foundation

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
