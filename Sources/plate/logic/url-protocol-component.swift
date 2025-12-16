import Foundation

extension String {
    public func replaceUnderscores(with string: String = ".") -> String {
        return self.replacingOccurrences(
            of: "_",
            with: string
        )
    }
}

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

public enum TopLevelDomainComponent: String, ProtocolComponent {
    case com
    case net
    case org
    case edu
    case gov
    case info
    case academy
    case io

    case nl
    case de
    case be
    case uk
    case il

    case co_uk
    case co_il

    public var component: String {
        return "." + self.rawValue.replaceUnderscores()
    }
}
