import Foundation

public enum ProjectError: Error, LocalizedError {
    case noPathStoredForKey(String)
    case assumedTargetDoesNotExist(String)

    public var errorDescription: String? {
        switch self {
        case .noPathStoredForKey(let key):
            return "No path has been stored for the key '\(key)'. Check your project structure configuration."
        case .assumedTargetDoesNotExist(let path):
            return "The assumed target at path '\(path)' does not exist. Verify the file or directory is present."
        }
    }

    public var failureReason: String? {
        switch self {
        case .noPathStoredForKey:
            return "The requested key could not be matched in the configured project paths."
        case .assumedTargetDoesNotExist:
            return "FileManager could not find any file or directory at the specified location."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .noPathStoredForKey:
            return "Ensure the key is registered in your ProjectStructure paths dictionary."
        case .assumedTargetDoesNotExist:
            return "Ensure the target file or directory exists, or correct the name in your code."
        }
    }

    public var helpAnchor: String? {
        switch self {
        case .noPathStoredForKey:
            return "project.paths.configuration"
        case .assumedTargetDoesNotExist:
            return "filesystem.target.validation"
        }
    }
}

