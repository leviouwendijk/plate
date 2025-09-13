import Foundation

public enum NumberParity: String, RawRepresentable, Sendable {
    case even
    case odd

    public init(number: Int) {
        self = Self.check(for: number)
    }

    public static func check(for num: Int) -> NumberParity {
        return plate.even(num) ? .even : .odd
    }
}

public func even(_ num: Int) -> Bool {
    // return (num % 2) == 0
    return (num & 1) == 0
}

public func odd(_ num: Int) -> Bool {
    return !even(num)
}

extension Int {
    public func parity() -> NumberParity {
        return NumberParity.init(number: self)
    }

    public func even() -> Bool {
        return plate.even(self)
    }

    public func odd() -> Bool {
        return plate.odd(self)
    }
}
