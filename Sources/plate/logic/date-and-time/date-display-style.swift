import Foundation

public enum DateDisplayStyle {
    // Custom patterns
    case yyyyMMdd                    // 2025-07-10
    case yyyyMMddHHmmss              // 2025-07-10 14:23:45
    case yyyyMMddTHHmmssZ             // 2025-07-10T14:23:45+0200
    case yyyyMMddTHHmmssSSSZZZZ       // 2025-07-10T14:23:45.123+02:00

    // ISO-8601 variants
    case iso8601                      // 2025-07-10T14:23:45Z
    case iso8601WithFractionalSeconds// 2025-07-10T14:23:45.123Z

    // RFC-1123 / HTTP-date
    case rfc1123                      // Thu, 10 Jul 2025 14:23:45 GMT

    // Locale-aware styles
    case shortDate                    // 7/10/25
    case mediumDate                   // Jul 10, 2025
    case longDate                     // July 10, 2025
    case fullDate                     // Thursday, July 10, 2025

    case shortTime                    // 2:23 PM
    case mediumTime                   // 2:23:45 PM
    case longTime                     // 2:23:45 PM GMT+02:00
    case fullTime                     // 2:23:45 PM Central European Summer Time

    public var dateFormat: String? {
        switch self {
        case .yyyyMMdd:                    return "yyyy-MM-dd"
        case .yyyyMMddHHmmss:              return "yyyy-MM-dd HH:mm:ss"
        case .yyyyMMddTHHmmssZ:             return "yyyy-MM-dd'T'HH:mm:ssZ"
        case .yyyyMMddTHHmmssSSSZZZZ:       return "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        case .iso8601:                      return "yyyy-MM-dd'T'HH:mm:ss'Z'"
        case .iso8601WithFractionalSeconds:return "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case .rfc1123:                      return "EEE, dd MMM yyyy HH:mm:ss zzz"
        case .shortDate, .mediumDate,
             .longDate, .fullDate,
             .shortTime, .mediumTime,
             .longTime, .fullTime:
            return nil
        }
    }

    public func formatter(
        locale: Locale = .current,
        customTimeZone: CustomTimeZone = .amsterdam
    ) throws -> DateFormatter {
        let df = DateFormatter()
        df.locale = locale
        df.timeZone = try customTimeZone.set()

        switch self {
        case .shortDate:
            df.dateStyle = .short; df.timeStyle = .none
        case .mediumDate:
            df.dateStyle = .medium; df.timeStyle = .none
        case .longDate:
            df.dateStyle = .long; df.timeStyle = .none
        case .fullDate:
            df.dateStyle = .full; df.timeStyle = .none
        case .shortTime:
            df.dateStyle = .none; df.timeStyle = .short
        case .mediumTime:
            df.dateStyle = .none; df.timeStyle = .medium
        case .longTime:
            df.dateStyle = .none; df.timeStyle = .long
        case .fullTime:
            df.dateStyle = .none; df.timeStyle = .full
        default:
            df.dateFormat = dateFormat
        }

        return df
    }
}

extension Date {
    public func display(
        as style: DateDisplayStyle,
        in timezone: CustomTimeZone = .amsterdam,
        locale: Locale = .current
    ) throws -> String {
        let fmt = try style.formatter(locale: locale, customTimeZone: timezone)
        return fmt.string(from: self)
    }
}

extension String {
    public func parseAndDisplay(
        parsing inputFormat: DateParserFormatting = .yyyyMMdd,
        to style: DateDisplayStyle,
        parsedIn inputZone: CustomTimeZone = .utc,
        displayedIn outputZone: CustomTimeZone,
        using calendar: Calendar = .current,
        locale: Locale = .current
    ) throws -> String {
        let comps = try dateComponents(as: inputFormat)
        let date  = try comps.toDate(using: calendar, inputZone)
        return try date.display(as: style, in: outputZone, locale: locale)
    }
}
