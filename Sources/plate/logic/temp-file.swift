import Foundation

public enum TemporaryFileError: Error {
    case writeError(String)
}

public func writeToTemporaryFile(content: String, fileExtension: String) throws -> URL {
    let tempDirectory = FileManager.default.temporaryDirectory
    let fileURL = tempDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension(fileExtension)

    do {
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    } catch {
        let message = "Error writing to temporary file at \(fileURL.path): \(error.localizedDescription)"
        throw TemporaryFileError.writeError(message)
    }
}

extension String {
    public func tempFile(fileExtension: String) throws -> URL {
        let url = try writeToTemporaryFile(content: self, fileExtension: fileExtension)
        return url
    }
}
