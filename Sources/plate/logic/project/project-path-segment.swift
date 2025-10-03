import Foundation

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
