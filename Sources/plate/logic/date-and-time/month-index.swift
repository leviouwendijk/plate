import Foundation

public enum MonthIndexError: Error {
    case invalidMonth(String)
}

public func monthIndex(from m: String) throws -> Int {
    let lower = m.lowercased()
    let names = Calendar.current.monthSymbols.map { $0.lowercased() }
    if let idx = names.firstIndex(of: lower) { return idx + 1 }
    let abbr = Calendar.current.shortMonthSymbols.map { $0.lowercased() }
    if let idx = abbr.firstIndex(of: lower) { return idx + 1 }
    if let n = Int(lower), (1...12).contains(n) { return n }
    throw MonthIndexError.invalidMonth(m)
}
