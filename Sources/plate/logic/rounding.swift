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

public enum RoundingOffsetDirection: Sendable {
    case up
    case down
}

// Extension for Double
extension Double: Roundable {
    public func roundTo(_ multiple: Double) -> Double {
        return (self / multiple).rounded() * multiple
    }

    public func offset(direction: RoundingOffsetDirection = .down, by offset: Double) -> Double {
        switch direction {
            case .up:
            return self + offset

            case .down:
            return self - offset
        }
    }

    public func roundThenOffset(
        to multiple: Double,
        direction: RoundingOffsetDirection = .down,
        by offset: Double
    ) -> Double {
        return self
        .roundTo(multiple)
        .offset(direction: direction, by: offset)
    }
}

// Extension for Int
extension Int: Roundable {
    public func roundTo(_ multiple: Int) -> Int {
        return ((self / multiple) * multiple)
    }
}

public protocol StringRoundable {
    func strnd(_ decimals: Int) -> String
}

extension Double: StringRoundable {
    public func strnd(_ decimals: Int = 2) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}
