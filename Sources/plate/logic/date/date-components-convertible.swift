import Foundation

public protocol DateConvertible {
    func toDate(using calendar: Calendar,_ timezone: CustomTimeZone) throws -> Date
}

extension DateComponents: DateConvertible { 
    @available(*, message: "Deprecated, improved the same api to use just .date()")
    public func toDate(
            using calendar: Calendar = .current,
            _ timezone: CustomTimeZone = .amsterdam
        ) throws -> Date {
            var cal = calendar
            cal.timeZone = try timezone.set()
            guard let date = cal.date(from: self) else {
                throw DateConversionError.invalidDateComponents
            }
        return date
    }

    public func date(
            using calendar: Calendar = .current,
            _ timezone: CustomTimeZone = .amsterdam
        ) throws -> Date {
            var cal = calendar
            cal.timeZone = try timezone.set()
            guard let date = cal.date(from: self) else {
                throw DateConversionError.invalidDateComponents
            }
        return date
    }
}
