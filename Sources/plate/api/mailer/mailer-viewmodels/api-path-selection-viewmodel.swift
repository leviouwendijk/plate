import SwiftUI
import Combine

public class MailerAPISelectionViewModel: ObservableObject {
    /// The currently selected route — `nil` means “no route chosen yet.”
    @Published public var selectedRoute: MailerAPIRoute? {
        didSet {
            // Whenever you pick a new route (or clear it), reset endpoint.
            if oldValue != selectedRoute {
                selectedEndpoint = nil
            }
        }
    }

    /// The currently selected endpoint (or `nil` for “none”).
    @Published public var selectedEndpoint: MailerAPIEndpoint?

    /// Array of endpoints valid for the current route, or empty if no route.
    public var validEndpoints: [MailerAPIEndpoint] {
        guard let route = selectedRoute else { return [] }
        return MailerAPIPath.endpoints(for: route)
    }

    /// Builds a `MailerAPIPath` only when both route & endpoint are non-nil and valid.
    public var apiPath: MailerAPIPath? {
        guard
            let route = selectedRoute,
            let endpoint = selectedEndpoint,
            MailerAPIPath.isValid(endpoint: endpoint, for: route)
        else {
            return nil
        }

        return try? MailerAPIPath(route: route, endpoint: endpoint)
    }

    public init(
        initialRoute: MailerAPIRoute? = nil,
        initialEndpoint: MailerAPIEndpoint? = nil
    ) {
        self.selectedRoute = initialRoute
        // Only keep an initial endpoint if it matches the initial route
        if
            let route = initialRoute,
            let endpoint = initialEndpoint,
            MailerAPIPath.isValid(endpoint: endpoint, for: route)
        {
            self.selectedEndpoint = endpoint
        } else {
            self.selectedEndpoint = nil
        }
    }
}
