import Foundation

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
        formatter.timeZone = try timezone.set()

        switch style {
          case .date:
            formatter.dateFormat = "yyyy-MM-dd"
          case .dateTime:
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        }

        return formatter.string(from: self)
    }
}

