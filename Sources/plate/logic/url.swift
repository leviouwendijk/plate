import Foundation

public enum URLKind {
    case string
    case path
}

extension String {
    public func url(_ kind: URLKind = .string) throws -> URL {
        switch kind {
        case .string:
            guard let u = URL(string: self) else {
                throw URLError(.badURL)
            }
            return u

        case .path:
            return URL(fileURLWithPath: self)
        }
    }
}
