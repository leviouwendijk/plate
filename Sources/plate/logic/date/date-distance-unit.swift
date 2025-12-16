import Foundation

public enum DateDistanceUnitError: Error, LocalizedError, Sendable {
    case combinedUnsupported

    public var errorDescription: String? {
        switch self {
        case .combinedUnsupported:
            return "The 'combined' unit is not supported in this context."
        }
    }
}

public enum DateDistanceUnit: String, CaseIterable, Sendable {
    case days
    case weeks
    case months
    case years
    case hours
    case minutes
    case seconds
    case milliseconds
    case combined

    public func components(count: Int) throws -> DateComponents {
        switch self {
        case .milliseconds:
            var dc = DateComponents()
            dc.nanosecond = count * 1_000_000
            return dc

        case .seconds:
            return plate.seconds(count)
        case .minutes:
            return plate.minutes(count)
        case .hours:
            return plate.hours(count)
        case .days:
            return plate.days(count)
        case .weeks:
            return plate.weeks(count)
        case .months:
            return plate.months(count)
        case .years:
            return plate.years(count)

        case .combined:
            throw DateDistanceUnitError.combinedUnsupported
        }
    }
}
