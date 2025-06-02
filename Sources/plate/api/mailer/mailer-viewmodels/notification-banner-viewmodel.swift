import SwiftUI
import Combine

public class NotificationBannerController: ObservableObject {
    @Published public var show: Bool
    @Published public var style: NotificationBannerType
    @Published public var message: String

    public init(
        show: Bool = false,
        style: NotificationBannerType = .info,
        message: String = "",
    ) {
        self.show = show
        self.style = style
        self.message = message
    }
}
