import Foundation

public enum ApplicationEnvironmentActorError: Error {
    case fileNotFound(String)
    case invalidConfigLine(String)
}

public struct ApplicationEnvironmentActor {
    public static func load(from filePath: String) throws -> [String: String] {
        let url = URL(fileURLWithPath: filePath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ApplicationEnvironmentActorError.fileNotFound(filePath)
        }
        
        let raw = try String(contentsOf: url, encoding: .utf8)
        var result: [String: String] = [:]
        
        for line in raw.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else {
                continue
            }
            
            let parts = trimmed.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else {
                throw ApplicationEnvironmentActorError.invalidConfigLine(trimmed)
            }
            
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1].trimmingCharacters(in: .whitespaces)
            result[key] = value
        }
        
        return result
    }
    
    public static func set(to loadedDictionary: [String: String]) {
        for (key, value) in loadedDictionary {
            setenv(key, value, 1)
        }
    }
}
