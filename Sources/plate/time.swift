import Foundation

public protocol SecondConvertible {
    func hoursToSeconds() -> Int
}

extension Int: SecondConvertible {
    public func hoursToSeconds() -> Int {
        return 3600 * self
    }
}
