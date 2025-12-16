import Foundation

extension TimeInterval {
    public var formattedDuration: String {
        let totalMinutes = Int(self / 60)
        let minutes = totalMinutes % 60

        let totalHours = totalMinutes / 60
        let hours = totalHours % 24

        let totalDays = totalHours / 24
        let days = totalDays % 7

        let weeks = totalDays / 7

        var components: [String] = []
        if weeks    > 0 { components.append("\(weeks)w") }
        if days     > 0 { components.append("\(days)d") }
        if hours    > 0 { components.append("\(hours)h") }
        if minutes  > 0 { components.append("\(minutes)m") }

        return components.isEmpty ? "0m" : components.joined(separator: " ")
    }
}
