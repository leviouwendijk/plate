import SwiftUI
import Combine

public struct NotificationBannerControllerContents {
    public let title: String
    public let style: NotificationBannerType
    public let message: String

    public init(
        title: String,
        style: NotificationBannerType,
        message: String
    ) {
        self.title = title
        self.style = style
        self.message = message
    }

    public static func fallback() -> NotificationBannerControllerContents {
        return NotificationBannerControllerContents(
            title: "defaultFallbackNotification",
            style: .error,
            message: "The title you provided for the controller does not exist"
        )
    }

    public static func error() -> NotificationBannerControllerContents {
        return NotificationBannerControllerContents(
            title: "defaultErrorNotification",
            style: .error,
            message: "Generic error (by NotificationBannerController)"
        )
    }

    public static func info() -> NotificationBannerControllerContents {
        return NotificationBannerControllerContents(
            title: "defaultInfoNotification",
            style: .info,
            message: "Generic info (by NotificationBannerController)"
        )
    }

    public static func success() -> NotificationBannerControllerContents {
        return NotificationBannerControllerContents(
            title: "defaultSuccessNotification",
            style: .success,
            message: "Generic success (by NotificationBannerController)"
        )
    }

    public static func defaults() -> [NotificationBannerControllerContents] {
        return [
            fallback(),
            info(),
            error(),
            success()
        ]
    }
}

@MainActor
public class NotificationBannerController: ObservableObject {
    @Published public var show: Bool = false
    @Published public var style: NotificationBannerType = .info
    @Published public var message: String = ""
    @Published public var contents: [NotificationBannerControllerContents] = []

    public var hide: Bool { return !show }

    public init(
        contents: [NotificationBannerControllerContents] = [],
        addingDefaultContents: Bool = false
    ) {
        var c: [NotificationBannerControllerContents] = []
        c.append(contentsOf: contents)
        if addingDefaultContents {
            c.append(contentsOf: NotificationBannerControllerContents.defaults())
        }
        self.contents = c
    }

    public func set(to name: String, useFallback: Bool = true) {
        if let co = contents.first(
            where: {
                $0.title == name
            }
        ) {
            self.style = co.style
            self.message = co.message
        } else {
            let fallback = NotificationBannerControllerContents.fallback()
            self.style = fallback.style
            self.message = fallback.message
        }
    }

    public func notify(delay: Int = 3) {
        withAnimation {
            self.show = true
        }
        
        let seconds = DispatchTimeInterval.seconds(delay)

        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            withAnimation { 
                self.show = false
            }
        }
    }

    public func setAndNotify(
        to name: String,
        useFallback: Bool = true,
        delay: Int = 3
    ) {
        self.set(to: name, useFallback: useFallback)
        self.notify(delay: delay)
    }

    public func reset() {
        self.show = false
    }
}
