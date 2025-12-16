import Foundation

@available(*, message: "Being deprecated in favor of Primitives.TimeZoneIdentifier")
public enum CustomTimeZone: String, Sendable {
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
    case israel   = "Asia/Jerusalem" 
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
    
    public func set() throws -> TimeZone {
        if let timezone = TimeZone(identifier: self.rawValue) {
            return timezone
        } else {
            throw DateConversionError.cannotSetCustomTimeZone
        }
    }
}
