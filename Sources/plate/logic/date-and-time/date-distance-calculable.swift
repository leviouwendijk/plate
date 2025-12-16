import Foundation

extension Date {
    public static func today() -> Date {
        return Date()
    }

    public func conforming(to format: String = "dd/MM/yyyy") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

protocol DateDistanceCalculable {
    func distance(to date: Date, in units: DateDistanceUnit) -> DateComponents
}

extension Date: DateDistanceCalculable {
    public func distance(to date: Date, in unit: DateDistanceUnit) -> DateComponents {
        let calendar = Calendar.current
        
        switch unit {
            case .days:
                return calendar.dateComponents([.day], from: self, to: date)

            case .weeks:
                return calendar.dateComponents([.weekOfYear], from: self, to: date)
                
            case .months:
                return calendar.dateComponents([.month], from: self, to: date)
                
            case .years:
                return calendar.dateComponents([.year], from: self, to: date)
                
            case .hours:
                return calendar.dateComponents([.hour], from: self, to: date)
                
            case .minutes:
                return calendar.dateComponents([.minute], from: self, to: date)
                
            case .seconds:
                return calendar.dateComponents([.second], from: self, to: date)
                
            case .milliseconds:
                let interval = date.timeIntervalSince(self)
                let millis = Int(interval * 1_000)
                return DateComponents(nanosecond: millis * 1_000_000)
                
            case .combined:
                return calendar.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second],
                    from: self,
                    to: date
                )
        }
    }
}
