import Foundation

public protocol DateRetrievable {
    func date(_ timezone: CustomTimeZone, as format: DateParserFormatting) throws -> Date
}

extension String {
    public func dateParts(by separators: [String] = ["-", "/", ".", "_", " "]) throws -> [String] { 
        for sep in separators {
            let parts = self.components(separatedBy: sep)
            guard parts.count == 3 else { continue }

            return parts
        }

        throw DateConversionError.cannotExtractDateParts
    }
}

extension String: DateRetrievable {
    public func dateComponents(as format: DateParserFormatting = .yyyyMMdd) throws -> DateComponents {
        let parts = try self.dateParts()
        return try format.components(from: parts)
    }

    public func date(
        _ timezone: CustomTimeZone = .amsterdam,
        as format: DateParserFormatting = .yyyyMMdd
    ) throws -> Date {
        let comps = try self.dateComponents(as: format)
        return try comps.toDate(using: .current, timezone)
    }
}
