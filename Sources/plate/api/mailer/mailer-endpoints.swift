import Foundation

public enum MailerAPIAlias: String, CaseIterable, RawRepresentable, Sendable {
    case betalingen
    case bevestigingen
    case offertes
    case relaties
    case support
    case intern

    fileprivate static let routeMap: [MailerAPIRoute: MailerAPIAlias] = [
        .invoice:     .betalingen,
        .appointment: .bevestigingen,
        .quote:       .offertes,
        .lead:        .relaties,
        .service:     .relaties,
        .resolution:  .relaties,
        .affiliate:   .relaties,
        .custom:      .relaties,
        .template:    .intern
    ]
}

public enum MailerAPIRoute: String, CaseIterable, RawRepresentable, Sendable {
    case quote
    case lead
    case appointment
    case affiliate
    case service
    case invoice
    case resolution
    case custom
    case template

    public func alias() -> String {
        MailerAPIAlias
        .routeMap[self]?.rawValue ?? "relaties"
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
    case fetch
    // case templateFetch  = "template/fetch"
    case messageSend    = "message/send"
}

public struct MailerAPIPath {
    public let route:    MailerAPIRoute
    public let endpoint: MailerAPIEndpoint

    public static let defaultBaseURLString: String = MailerAPIRequestDefaults.defaultBaseURL()

    public static var defaultBaseURL: URL {
        let base = MailerAPIRequestDefaults.defaultBaseURL()
        guard let url = URL(string: base) else {
            fatalError("Invalid default base URL: “\(base)”")
        }
        return url
    }

    private static let validMap: [MailerAPIRoute:Set<MailerAPIEndpoint>] = [
        .invoice:    [.issue, .expired, .issueSimple],
        .quote:      [.issue, .follow],
        .lead:       [.confirmation, .follow, .check],
        .service:    [.onboarding, .follow],
        .resolution: [.review, .follow],
        .affiliate:  [.food],
        .custom:     [.messageSend],
        .template:   [.fetch]
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

    public func url(baseURL: URL = defaultBaseURL) throws -> URL {
        let str = "\(baseURL.absoluteString)/\(route.rawValue)/\(endpoint.rawValue)"
        guard let url = URL(string: str) else {
            throw MailerAPIError.invalidURL(str)
        }
        return url
    }

    public func string(baseURL: String = defaultBaseURLString) -> String {
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
