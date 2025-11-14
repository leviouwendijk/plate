import Foundation

public enum LogLevel: Int, Comparable, CustomStringConvertible {
    case info, warn, error, critical, debug

    public var label: String {
        switch self {
        case .info:  return "INFO"
        case .warn:  return "WARN"
        case .error: return "ERROR"
        case .critical: return "CRITICAL"
        case .debug: return "DEBUG"
        }
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var description: String {
        return self.label.lowercased()
    }
}
