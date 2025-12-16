import Foundation

public struct FieldValue<Value: Codable & Sendable, Tag: Codable & Sendable>: Codable, Sendable {
    public let value: Value
    public let type: Tag

    @inlinable
    public init(value: Value, type: Tag) {
        self.value = value
        self.type = type
    }
}
