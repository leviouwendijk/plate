import Foundation

public enum StandardLoggerError: Error, LocalizedError, Sendable {
    case symbolResolvedToNull
    case failedToCreateLogFile(String)
    case failedToWriteLog(String)
    case failedToCloseFile(String)
    case invalidLogLevel(String)
    case logFileNotConfigured
    
    public var errorDescription: String? {
        switch self {
        case .symbolResolvedToNull:
            return "Cannot initialize from a nil value symbol"
        case .failedToCreateLogFile(let path):
            return "Failed to create log file at: \(path)"
        case .failedToWriteLog(let reason):
            return "Failed to write to log: \(reason)"
        case .failedToCloseFile(let reason):
            return "Failed to close log file: \(reason)"
        case .invalidLogLevel(let level):
            return "Invalid log level: \(level)"
        case .logFileNotConfigured:
            return "Log file has not been configured"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .symbolResolvedToNull:
            return "Symbol provided to init(symbol: String?) for environment extraction resolved to nil value"
        case .failedToCreateLogFile:
            return "The directory or file system may not be writable"
        case .failedToWriteLog:
            return "The log file may be closed or inaccessible"
        case .failedToCloseFile:
            return "The file handle may already be closed"
        case .invalidLogLevel:
            return "Log level must be one of: debug, info, warn, error, critical"
        case .logFileNotConfigured:
            return "Configure the log file before attempting to log"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .symbolResolvedToNull:
            return "Ensure the provided symbol resolves for correct initialization"
        case .failedToCreateLogFile(let path):
            return "Ensure the directory exists and is writable: \(path)"
        case .failedToWriteLog:
            return "Reconfigure the log file and try again"
        case .failedToCloseFile:
            return "The file may have already been closed, which is safe to ignore"
        case .invalidLogLevel(let level):
            return "Use one of these levels instead: debug, info, warn, error, critical, not \(level)"
        case .logFileNotConfigured:
            return "Call configure(logFileURL:) with a valid file path"
        }
    }
}
