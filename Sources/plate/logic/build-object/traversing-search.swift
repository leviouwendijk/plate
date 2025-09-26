import Foundation

enum TraverseError: Error, LocalizedError {
    case fileNotFound(buildFile: String, maxDepth: Int, startURL: URL)
    
    var errorDescription: String? {
        switch self {
        case let .fileNotFound(buildFile, maxDepth, startURL):
            return "Could not find '\(buildFile)' within \(maxDepth) levels starting at \(startURL.path)"
        }
    }
}

public func traversingSearch(
    from startURL: URL = Bundle.main.bundleURL,
    maxDepth: Int = 5,
    searching targetFile: String
) throws -> URL {
    var url = startURL
    let fm = FileManager.default
    var depth = 0

    while depth < maxDepth {
        let candidate = url.appendingPathComponent(targetFile)
        if fm.fileExists(atPath: candidate.path) {
            return candidate
        }
        let parent = url.deletingLastPathComponent()
        guard parent.path != url.path else { break }
        url = parent
        depth += 1
    }

    throw TraverseError.fileNotFound(
        buildFile: targetFile,
        maxDepth: maxDepth,
        startURL: startURL
    )
}
