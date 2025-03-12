import Foundation

public protocol SecondConvertible {
    func hoursToSeconds() -> Double
}

extension Int: SecondConvertible {
    public func hoursToSeconds() -> Double {
        return Double(3600) * Double(self)
    }
}

extension Double: SecondConvertible {
    public func hoursToSeconds() -> Double {
        return 3600 * self
    }
}
