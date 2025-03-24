import Foundation

public struct APIVersion {
    public let version: Int

    public init(version: Int) {
        self.version = version
    }

    public var description: String {
        return "v\(version)"
    }
}

public struct APIEndpoint {
    public let route: String
    public let endpoint: String
    public let details: String

    public init(route: String, endpoint: String, details: String = "") {
        self.route = route
        self.endpoint = endpoint
        self.details = details
    }

    public func string() -> String {
        return route + "/" + endpoint
    }
}

public enum APIURLProtocol: String, RawRepresentable {
    case http
    case https
    case ws
    case wss
}

public struct APIConfiguration {
    public let _protocol: APIURLProtocol
    public let domain: String
    public let apiName: String
    public let version: APIVersion
    public let endpoints: [APIEndpoint]

    public init(
        _protocol: APIURLProtocol = APIURLProtocol.https,
        domain: String,
        apiName: String,
        version: APIVersion,
        endpoints: [APIEndpoint]
    ) {
        self._protocol = _protocol
        self.domain = domain
        self.apiName = apiName
        self.version = version
        self.endpoints = endpoints
    }

    public func baseUrlString() -> String {
        return "\(self._protocol.rawValue)://\(self.domain)/\(self.apiName)/\(self.version.description)"

    }

    public func endpoint(_ route: String,_ name: String) -> String {
        guard let selectedEndpoint = endpoints.first(where: { $0.endpoint == name && $0.route == route }) else {
            return baseUrlString() + "/" + route + "/" + name
        }
        return baseUrlString() + "/" + selectedEndpoint.string()
    }
}
