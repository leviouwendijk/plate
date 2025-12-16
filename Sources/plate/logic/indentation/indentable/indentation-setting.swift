import Foundation

public struct IndentationSetting: Codable, Sendable {
    public var size: Int
    public var times: Int
    public var skip: Bool
    
    public init(
        size: Int = 4,
        times: Int = 1,
        skip: Bool = false
    ) {
        self.size = size
        self.times = times
        self.skip = skip
    }

    public var indent: String {
        return plate.indentation(size: size, times: 1)
    }

    public var indentation: String {
        return plate.indentation(size: size, times: times)
    }
}
