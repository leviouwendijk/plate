import SwiftUI
import Combine

public class NotificationBannerController: ObservableObject {
    @Published public var show: Bool
    @Published public var type: NotificationBannerType
    @Published public var message: String

    public init(
        show: Bool = false,
        type: NotificationBannerType = .info,
        message: String = "",
    ) {
        self.show = show
        self.type = type
        self.message = message
    }
}
