import Foundation

public struct StandardDateFormatter {
    public static var postgres: ISO8601DateFormatter {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
            .withColonSeparatorInTimeZone
        ]
        return fmt
    }
}

public extension Date {
    var postgresTimestamp: String {
        StandardDateFormatter.postgres.string(from: self)
    }
}
