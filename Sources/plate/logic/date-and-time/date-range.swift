import Foundation

public struct DateRange: Sendable {
    public let start: Date
    public let end: Date
    
    public init(
        start: Date,
        end: Date
    ) {
        self.start = start
        self.end = end
    }

    public init(using dates: (from: Date, to: Date)) {
        self.start = dates.from
        self.end = dates.to
    }
    
    public init(from start: String, to end: String) throws {
        let s = try start.date()
        let e = try end.date()

        self.init(using: (from: s, to: e))
    }

    public init(from start: String, interval: DateComponents) throws {
        let s = try start.date()
        let e = s + interval

        self.init(using: (from: s, to: e))
    }

    public func string(in format: String = "dd/MM/yyyy") -> String {
        return "\(start.conforming(to: format)) - \(end.conforming(to: format))"
    }
}
