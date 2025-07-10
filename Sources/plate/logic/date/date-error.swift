import Foundation

public enum DateConversionError: Error {
    case invalidDateComponents
    case invalidStringFormat
    case cannotExtractDateParts
    case cannotSetCustomTimeZone
}

public enum DateFormattingError: Error {
    case unsupportedStyle
    case badStringForSelectedFormat
}
