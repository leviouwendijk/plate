import Foundation

public enum YearlyQuarterError: Error, LocalizedError {
    case invalidMonth(month: Int)
    
    public var errorDescription: String? {
        switch self {
            case .invalidMonth(let month):
                return "Cannot retrieve quarter for provided month: \(month)"
        }
    }
}

public enum YearlyQuarter: UInt8, Sendable, Codable {
    case q1 = 1
    case q2 = 2
    case q3 = 3
    case q4 = 4

    public static func from(month: Int) throws -> YearlyQuarter {
        switch month {
            case 1...3:
                return .q1

            case 4...6:
                return .q2

            case 7...9:
                return .q3

            case 10...12:
                return .q4
            
            default:
                throw YearlyQuarterError.invalidMonth(month: month)
        }
    }
}

extension Int {
    public func yearlyQuarter() throws -> YearlyQuarter {
        try YearlyQuarter.from(month: self)
    }
}
