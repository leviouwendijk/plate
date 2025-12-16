import Foundation

public struct IndentationOverride: Codable, Sendable {
    public let index: [Int: IndentationSetting]
    
    public init(
        index: [Int: IndentationSetting]
    ) {
        self.index = index
    }

    public init(
        _ index: [Int: IndentationSetting]
    ) {
        self.index = index
    }
}
