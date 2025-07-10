import Foundation

public enum DateParserFormatting: Sendable {
    case yyyyMMdd
    case ddMMyyyy
    case mmDDyyyy
    case yyyyDDmm
    
    public func components(from parts: [String]) throws -> DateComponents {
        let year: Int?
        let month: Int?
        let day: Int?

        switch self {
        case .yyyyMMdd:
            if parts[0].count == 4, parts[1].count == 2, parts[2].count == 2 {
                year  = Int(parts[0])
                month = Int(parts[1])
                day   = Int(parts[2])
            } else {
                throw DateFormattingError.badStringForSelectedFormat
            }

        case .ddMMyyyy:
            if parts[0].count == 2, parts[1].count == 2, parts[2].count == 4 {
                day   = Int(parts[0])
                month = Int(parts[1])
                year  = Int(parts[2])
            } else {
                throw DateFormattingError.badStringForSelectedFormat
            }

        case .mmDDyyyy:
            if parts[0].count == 2, parts[1].count == 2, parts[2].count == 4 {
                month   = Int(parts[0])
                day     = Int(parts[1])
                year    = Int(parts[2])
            } else {
                throw DateFormattingError.badStringForSelectedFormat
            }

        case .yyyyDDmm:
            if parts[0].count == 4, parts[1].count == 2, parts[2].count == 2 {
                year  = Int(parts[0])
                day   = Int(parts[1])
                month = Int(parts[2])
            } else {
                throw DateFormattingError.badStringForSelectedFormat
            }
        }

        guard let y = year, let m = month, let d = day else {
            throw DateFormattingError.badStringForSelectedFormat
        }

        var comps = DateComponents()
        comps.year  = y
        comps.month = m
        comps.day   = d
        return comps
    }
}
