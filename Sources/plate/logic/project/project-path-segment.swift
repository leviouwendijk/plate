import Foundation

public protocol ProjectSegmentable: Sendable, Codable {
    var value: String { get set }
    var type: ProjectPathSegmentType? { get set }
}

public struct ProjectPathSegment: ProjectSegmentable {
    public var value: String
    public var type: ProjectPathSegmentType?
    
    public init(
        value: String,
        type: ProjectPathSegmentType? = nil
    ) {
        self.value = value
        self.type = type
    }

    public init(
        _ value: String,
        _ type: ProjectPathSegmentType? = nil
    ) {
        self.value = value
        self.type = type
    }
}
