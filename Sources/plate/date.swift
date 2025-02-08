// Will also return rollover dates for "wrong" input components
//
// About date values in Swift:
// `Date` values are always converted to unified standard of the UTC timezone
// We can specify, when inputting a date, to ensure we note the UTC equivalent of our own timezone
// This way, we input our local date/time, and the UTC value will be adjusted to respect it
// However, this means that dates are *always* stored as UTC
// This causes no problems for passing `Date` types around, since these will adhere to our equivalent
// But when Formatting a date, we must instruct Swift to use our specific timezone, again, to display it in
// This way, we will be able to see the value--if all is correct--that we originally put in
//
import Foundation

// Set timezone variable
public enum CustomTimeZone: String {
    case utc = "UTC"
    case amsterdam = "Europe/Amsterdam"
    
    var set: TimeZone {
        return TimeZone(identifier: self.rawValue) ?? TimeZone.current
    }
}

public enum DateConversionError: Error {
    case invalidDateComponents
    case invalidStringPassed
}

func defaultDate() -> Date {
    let calendar = Calendar(identifier: .gregorian)
    let defaultComponents = DateComponents(year: 1, month: 1, day: 1, hour: 0, minute: 0, second: 0)
    let defaultDate = calendar.date(from: defaultComponents)!
    return defaultDate
}

// DateComponents -> Date
public protocol DateConvertible {
    func toDate(using calendar: Calendar, timezone: CustomTimeZone) -> Date
}

extension DateComponents: DateConvertible {
    public func toDate(using calendar: Calendar = .current, timezone: CustomTimeZone = .amsterdam) -> Date {
        var calendar = calendar
        calendar.timeZone = timezone.set

        if let date = calendar.date(from: self) {
            return date
        } else {
            return defaultDate()
        }
    }
}

// String -> DateComponents
public protocol DateRetrievable {
    func date() -> Date
}

extension String {
    public func date() -> Date {
        let components = self.split(separator: "-")

        guard components.count == 3,
            components[0].count == 4,
            components[1].count == 2,
            components[2].count == 2,
            let year = Int(components[0]), 
            let month = Int(components[1]), 
            let day = Int(components[2]) else {
            return defaultDate()
        }
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        return dateComponents.toDate() // will either return date from inputs or defaultDate() value
    }
}

// Formatted date with correct timezone display
public protocol Formattable {
    func format(to timezone: CustomTimeZone,_ style: DateStyle) -> String
}

public enum DateStyle {
    case date
    case dateTime
}

extension Date: Formattable {
    public func format(to timezone: CustomTimeZone = .amsterdam,_ style: DateStyle) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timezone.set
        
        switch style {
            case .date: 
            formatter.dateFormat = "yyyy-MM-dd"
            case .dateTime: 
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        }
        return formatter.string(from: self)
    }
}

