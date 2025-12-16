import Foundation

extension String {
    public func path_url() -> URL {
        return URL(fileURLWithPath: self)
    }
}

extension Array where Element == String {
    public func path_urls() -> [URL] {
        return self.map { $0.path_url() }
    }
}
