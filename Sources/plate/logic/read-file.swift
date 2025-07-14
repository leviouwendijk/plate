import Foundation

public enum FileReadingError: Error, LocalizedError {
    case fileNotFound(path: String)
    case encodingError(path: String, encoding: String.Encoding)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found for reading at provided path: \(path)"
        case .encodingError(let path, let encoding):
            return "Failure to decode file at path: \(path) using encoding: \(encoding)"
        }
    }
}

public func readFile(
    at path: String,
    encoding: String.Encoding = .utf8
) throws -> String {
    let fileManager = FileManager.default

    guard fileManager.fileExists(atPath: path) else {
        throw FileReadingError.fileNotFound(path: path)
    }

    do {
        return try String(contentsOfFile: path, encoding: encoding)
    } catch {
        throw FileReadingError.encodingError(path: path, encoding: encoding)
    }
}
