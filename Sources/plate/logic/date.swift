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
    
    // North America
    case hawaii = "Pacific/Honolulu"         // UTC-10
    case alaska = "America/Anchorage"         // UTC-9
    case pacific = "America/Los_Angeles"        // UTC-8
    case mountain = "America/Denver"          // UTC-7
    case central = "America/Chicago"          // UTC-6
    case eastern = "America/New_York"         // UTC-5
    case atlantic = "America/Halifax"         // UTC-4
    
    // South America
    case brazil = "America/Sao_Paulo"         // UTC-3
    
    // Europe & Africa
    case london = "Europe/London"             // UTC+0
    case amsterdam = "Europe/Amsterdam"       // UTC+1
    case athens = "Europe/Athens"             // UTC+2
    case moscow = "Europe/Moscow"             // UTC+3
    
    // Middle East & South Asia
    case dubai = "Asia/Dubai"                 // UTC+4
    case kolkata = "Asia/Kolkata"             // UTC+5:30
    case dhaka = "Asia/Dhaka"                 // UTC+6
    
    // Southeast Asia
    case bangkok = "Asia/Bangkok"             // UTC+7
    case hongKong = "Asia/Hong_Kong"           // UTC+8
    
    // East Asia & Oceania
    case tokyo = "Asia/Tokyo"                 // UTC+9
    case sydney = "Australia/Sydney"          // UTC+10
    case auckland = "Pacific/Auckland"        // UTC+12
    
    var set: TimeZone {
        return TimeZone(identifier: self.rawValue) ?? TimeZone.current
    }
}

public enum DateConversionError: Error {
    case invalidDateComponents
    case invalidStringFormat
}

public enum DateFormattingError: Error {
  case unsupportedStyle
}

// func defaultDate() -> Date {
//     let calendar = Calendar(identifier: .gregorian)
//     let defaultComponents = DateComponents(year: 1, month: 1, day: 1, hour: 0, minute: 0, second: 0)
//     let defaultDate = calendar.date(from: defaultComponents)!
//     return defaultDate
// }

// DateComponents -> Date
public protocol DateConvertible {
    func toDate(using calendar: Calendar,_ timezone: CustomTimeZone) throws -> Date
}

extension DateComponents: DateConvertible { 
    public func toDate(
            using calendar: Calendar = .current,
            _ timezone: CustomTimeZone = .amsterdam
        ) throws -> Date {
            var cal = calendar
            cal.timeZone = timezone.set
            guard let date = cal.date(from: self) else {
                throw DateConversionError.invalidDateComponents
            }
        return date
    }
}

// String -> DateComponents
public protocol DateRetrievable {
    func date(_ timezone: CustomTimeZone, separator: String?) throws -> Date
}

extension String: DateRetrievable {
    public func date(
        _ timezone: CustomTimeZone = .amsterdam,
        separator: String? = nil
    ) throws -> Date {
        let separators = separator.map { [$0] } ?? ["-", "/", ".", "_"]

        for sep in separators {
            let components = self.components(separatedBy: sep)
            guard components.count == 3,
                  components[0].count == 4,
                  components[1].count == 2,
                  components[2].count == 2,
                  let year = Int(components[0]),
                  let month = Int(components[1]),
                  let day = Int(components[2]) else {
                continue
            }

            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day

            return try dateComponents.toDate(using: .current, timezone)
        }

        throw DateConversionError.invalidStringFormat
    }
}

// Formatted date with correct timezone display
public protocol DateTimeFormattable {
    func format(to timezone: CustomTimeZone,_ style: DateStyle) throws -> String
}

public enum DateStyle {
    case date
    case dateTime
}

extension Date: DateTimeFormattable {
    public func format(
        to timezone: CustomTimeZone = .amsterdam,
        _ style: DateStyle = .dateTime
    ) throws -> String {
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

