import Foundation

public enum MailerAPIRoute: String, CaseIterable, RawRepresentable, Sendable {
    case quote
    case lead
    case appointment
    case affiliate
    case service
    case invoice
    case resolution
    case custom

    public func alias() -> String {
        switch self {
            case .invoice:
                return "betalingen"
            case .appointment:
                return "bevestigingen"
            case .quote:
                return "offertes"
            case .lead:
                return "relaties"
            case .service:
                return "relaties"
            case .resolution:
                return "relaties"
            case .affiliate:
                return "relaties"
            case .custom:
                return "relaties"
        }
    }
}

public enum MailerAPIEndpoint: String, CaseIterable, RawRepresentable, Sendable {
    case confirmation
    case issue
    case issueSimple = "issue/simple"
    case follow
    case expired
    case onboarding
    case review
    case check
    case food
    case templateFetch  = "template/fetch"
    case messageSend    = "message/send"
}

public struct MailerAPIPath {
    public let route:    MailerAPIRoute
    public let endpoint: MailerAPIEndpoint

    private static let validMap: [MailerAPIRoute:Set<MailerAPIEndpoint>] = [
        .invoice:    [.issue, .expired, .issueSimple],
        .quote:      [.issue, .follow],
        .lead:       [.confirmation, .follow, .check],
        .service:    [.onboarding, .follow],
        .resolution: [.review, .follow],
        .affiliate:  [.food],
        .custom:     [.templateFetch, .messageSend]
    ]

    public init(
        route: MailerAPIRoute,
        endpoint: MailerAPIEndpoint
    ) throws {
        guard
          let allowed = MailerAPIPath.validMap[route],
          allowed.contains(endpoint)
        else {
          throw MailerAPIError.invalidEndpoint(route: route, endpoint: endpoint)
        }
        self.route = route
        self.endpoint = endpoint
    }

    public func url(baseURL: URL) throws -> URL {
        let str = "\(baseURL.absoluteString)/\(route.rawValue)/\(endpoint.rawValue)"
        guard let url = URL(string: str) else {
            throw MailerAPIError.invalidURL(str)
        }
        return url
    }

    public func string(baseURL: String = MailerAPIEnvironmentKey.apiURL.rawValue) -> String {
        return "\(baseURL)/\(route.rawValue)/\(endpoint.rawValue)"
    }

    public static func endpoints(for route: MailerAPIRoute) -> [MailerAPIEndpoint] {
        return Array(validMap[route] ?? [])
    }
}

// public struct MailerAPIRequestURL {
//     public let route: MailerAPIRoute
//     public let endpoint: MailerAPIEndpoint

//     public init(route: MailerAPIRoute, endpoint: MailerAPIEndpoint) {
//         self.route = route
//         self.endpoint = endpoint
//     }

//     public func url(baseURL: String = MailerAPIEnvironmentKey.apiURL.rawValue) -> URL {
//         let urlString = "\(baseURL)/\(route.rawValue)/\(endpoint.rawValue)"
//         return URL(string: urlString)!
//     }

//     public func string(baseURL: String = MailerAPIEnvironmentKey.apiURL.rawValue) -> String {
//         return "\(baseURL)/\(route.rawValue)/\(endpoint.rawValue)"
//     }
// }
