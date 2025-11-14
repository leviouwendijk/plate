import Foundation

public protocol Loggable: RawRepresentable, Comparable, Sendable, CaseIterable, Codable
where RawValue == String {
    var precedence: Int { get }
    var label: String { get }
}

public extension Loggable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        // lhs.precedence < rhs.precedence
        lhs.precedence > rhs.precedence
    }
}

// public enum LogLevel: Int, Sendable, Codable, Comparable, CustomStringConvertible {
//     case info, warn, error, critical, debug

//     public var label: String {
//         switch self {
//         case .info:  return "INFO"
//         case .warn:  return "WARN"
//         case .error: return "ERROR"
//         case .critical: return "CRITICAL"
//         case .debug: return "DEBUG"
//         }
//     }

//     public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
//         lhs.rawValue < rhs.rawValue
//     }

//     public var description: String {
//         return self.label.lowercased()
//     }
// }

public enum LogLevel: String, Loggable {
    case debug 
    case info 
    case warn 
    case error 
    case critical 
    
    public var precedence: Int {
        switch self {
        case .critical:  return 0
        case .error:     return 1
        case .warn:      return 2
        case .info:      return 3
        case .debug:     return 4
        }
    }
    
    public var label: String {
        return self.rawValue.uppercased()
    }
}
