import Foundation

public struct IndentationOptions: Codable, Sendable {
    public var size: Int
    public var times: Int
    public var overrides: [IndentationOverride]
    
    public init(
        size: Int = 4,
        times: Int = 1,
        overrides: [IndentationOverride] = []
    ) {
        self.size = size
        self.times = times
        self.overrides = overrides
    }

    public var defaultSetting: IndentationSetting {
        IndentationSetting(size: size, times: times, skip: false)
    }

    public func setting(for index: Int) -> IndentationSetting {
        var setting = defaultSetting

        for override in overrides {
            if let s = override.index[index] {
                setting = s
            }
        }

        return setting
    }
}
