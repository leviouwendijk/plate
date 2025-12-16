import Foundation

public enum TimeDistanceError: Error, LocalizedError {
    case invalidUnit
    case componentUnavailable(unit: DateDistanceUnit)
    
    public var errorDescription: String? {
        switch self {
        case .invalidUnit:
            return "Cannot use `.combined` when asking for a single integer."
        case .componentUnavailable(let unit):
            return "Calendar failed to produce a '\(unit.rawValue)' component."
        }
    }
}

public enum TimeDistanceCalculationMethod: String, RawRepresentable, CaseIterable, Sendable, StringParsableEnum {
    case until // until or up to
    case through // including the end, or 'through'

    public var infix: String {
        switch self {
            case .until:
            return "tot"
            case .through:
            return "tot en met"
        }
    }
}

public func timeDistance(
    from start: Date,
    to end: Date,
    in unit: DateDistanceUnit,
    calculating method: TimeDistanceCalculationMethod = .until
) throws -> Int {
    let calendar = Calendar.current
    
    func singleComponent(_ comp: Calendar.Component, for unit: DateDistanceUnit) throws -> Int {
        let components = calendar.dateComponents([comp], from: start, to: end)
        guard let value = components.value(for: comp) else {
            throw TimeDistanceError.componentUnavailable(unit: unit)
        }
        return value
    }
    
    let raw: Int
    switch unit {
        case .milliseconds:
            let interval = end.timeIntervalSince(start)
            raw = Int(interval * 1_000)

        case .seconds:
            raw = try singleComponent(.second, for: .seconds)

        case .minutes:
            raw = try singleComponent(.minute, for: .minutes)

        case .hours:
            raw = try singleComponent(.hour,   for: .hours)

        case .days:
            raw = try singleComponent(.day,    for: .days)

        case .weeks:
            raw = try singleComponent(.weekOfYear, for: .weeks)

        case .months:
            raw = try singleComponent(.month,  for: .months)

        case .years:
            raw = try singleComponent(.year,   for: .years)

            
        case .combined:
            throw TimeDistanceError.invalidUnit
    }

    switch method {
        case .until:
            return raw
        case .through:
            return raw + 1
    }
}

public struct TimeDistance: Sendable {
    public let start: String
    public let end: String
    public let method: TimeDistanceCalculationMethod

    public let startDate: Date
    public let endDate: Date

    public init(
        start: String,
        end: String,
        method: TimeDistanceCalculationMethod
    ) throws {
        self.start = start
        self.end = end
        self.startDate = try start.date()
        self.endDate = try end.date()
        self.method = method
    }

    public var string: String {
        return "\(start) \(method.infix) \(end)"
    }

    public func distance(in unit: DateDistanceUnit) throws -> Int {
        return try timeDistance(from: startDate, to: endDate, in: unit, calculating: method)
    }
}
