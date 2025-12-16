import Foundation

public protocol ProtocolComponent: Sendable, Codable, RawRepresentable where RawValue == String {
    var component: String { get }
}

public enum HTTPProtocolComponent: String, ProtocolComponent {
    case http
    case https

    public var component: String {
        return self.rawValue + "://"
    }
}
