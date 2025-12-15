import Foundation

#if canImport(AppKit)
import AppKit
#endif

public enum PathOpenerOpeningMethod {
    case direct
    case inParentDirectory
}

public enum PathOpenerError: Error, LocalizedError {
    case notFound(path: String)
    case unsupportedPlatform
    
    public var errorDescription: String? {
        switch self {
        case .notFound(let path):
            return "Path not found at \(path)"
        case .unsupportedPlatform:
            return "Unsupported platform"
        }
    }
}

public struct PathOpener {
    public let url: URL
    public let isDirectory: Bool
    public let method: PathOpenerOpeningMethod

    public init(path: String, method: PathOpenerOpeningMethod = .direct) throws {
        let fileURL = URL(fileURLWithPath: path)
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDir) else {
            throw PathOpenerError.notFound(path: path)
        }
        self.url = fileURL
        self.isDirectory = isDir.boolValue
        self.method = method
    }

    public func open() throws {
        let targetURL: URL
        switch method {
        case .direct:
            targetURL = url
        case .inParentDirectory:
            targetURL = url.deletingLastPathComponent()
        }

        #if os(macOS)
        switch method {
        case .direct:
            NSWorkspace.shared.open(targetURL)
        case .inParentDirectory:
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
        #elseif os(iOS)
        throw PathOpenerError.unsupportedPlatform
        #else
        throw PathOpenerError.unsupportedPlatform
        #endif
    }

    public func contents() throws -> [URL] {
        guard isDirectory else {
            return []
        }
        return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    }
}
