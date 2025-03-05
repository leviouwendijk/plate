import Foundation

// Function to round a Double and return an Int
public func roundedToInt(_ value: Double) -> Int {
    return Int(value.rounded())
}

// backwards compatibility
extension Double {
    public func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// new extension to round faster, to 2 decimals by default
extension Double {
    public func rnd(_ decimals: Int = 2) -> Double {
        let divisor = pow(10.0, Double(decimals))
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

// formatting Doubles inline to decimal-rounded String
public protocol StringRoundable {
    func strnd(_ value: Self,_ decimals: Int) -> String
}

extension Double: StringRoundable {
    public func strnd(_ value: Double,_ decimals: Int = 2) -> String {
        return String(format: "%.\(decimals)f", value)
    }
}
