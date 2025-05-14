import Foundation
import SwiftUI

public enum NotificationBannerType: String, RawRepresentable {
    case info
    case error
    case warning
    case success
}

public struct NotificationBanner: View {
    public let type: NotificationBannerType
    public let message: String

    public init(
        type: NotificationBannerType = .info,
        message: String,
    ) {
        self.type = type
        self.message = message
    }

    private var bannerColor: Color {
        switch type {
        case .info:
            return Color.gray.opacity(0.9)
        case .warning:
            return Color.yellow
        case .error:
            return Color.red
        case .success:
            return Color.green
        }
    }

    private var foregroundColor: Color {
        switch type {
        case .info, .warning:
            return Color.black
        case .error, .success:
            return Color.white
        }
    }

    private var imageSystemName: String {
        switch type {
        case .info:
            return "info.circle"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.octagon.fill"
        case .success:
            return "checkmark.seal.fill"
        }
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: imageSystemName)
                .font(.headline)
                .accessibilityHidden(true)

            Text(message)
                .font(.subheadline)
                .bold()
        }
        .foregroundColor(foregroundColor)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(bannerColor)
        .cornerRadius(8)
        // .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: message)
    }
}
