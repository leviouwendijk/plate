import Foundation

public struct LoadableResource {
    public let name: String
    public let fileExtension: String

    public init(
        name: String,
        fileExtension: String
    ) {
        self.name = name
        self.fileExtension = fileExtension
    }

    public func content() throws -> String {
        return try ResourceLoader.contents(of: self)
    }

    public func path() throws -> String {
        return try ResourceLoader.path(of: self)
    }
}

public struct ResourceLoader {
    public static func contents(of file: LoadableResource) throws -> String {
        guard let fileURL = Bundle.module.url(forResource: file.name, withExtension: file.fileExtension) else {
            throw ResourceError.notFound(resourceName: file.name, resourceType: file.fileExtension)
        }
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        return content
    }

    public static func path(of file: LoadableResource) throws -> String {
        guard let fileURL = Bundle.module.url(forResource: file.name, withExtension: file.fileExtension) else {
            throw ResourceError.notFound(resourceName: file.name, resourceType: file.fileExtension)
        }
        return fileURL.path
    }
}

