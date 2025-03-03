import Foundation

// Function to round a Double and return an Int
public func roundedToInt(_ value: Double) -> Int {
    return Int(value.rounded())
}

// Extension to round double to specified decimal places
extension Double {
    public func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// protocol that takes argument to round to
public protocol Roundable {
    func roundTo(_ multiple: Self) -> Self
}

// Extension for Double
extension Double: Roundable {
    public func roundTo(_ multiple: Double) -> Double {
        return (self / multiple).rounded() * multiple
    }
}

// Extension for Int
extension Int: Roundable {
    public func roundTo(_ multiple: Int) -> Int {
        return ((self / multiple) * multiple)
    }
}
