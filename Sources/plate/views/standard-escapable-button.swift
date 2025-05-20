import Foundation
import SwiftUI

public struct StandardEscapableButton: View {
    public let type: StandardButtonType
    public let title: String
    public let cancelTitle: String?
    public let subtitle: String
    public let action: () -> Void
    public let animationDuration: TimeInterval

    @State private var isPressed: Bool = false
    @Environment(\.isEnabled) private var isEnabled: Bool

    @State private var buttonSize: CGSize = .zero
    @State private var isCanceling: Bool = false

    public init(
        type: StandardButtonType,
        title: String,
        cancelTitle: String? = nil,
        subtitle: String = "",
        animationDuration: Double = 0.2,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.title = title
        self.cancelTitle = cancelTitle
        self.subtitle = subtitle
        self.animationDuration = animationDuration
        self.action = action
    }

    private var buttonColor: Color {
        if isCanceling {
            return Color.red.opacity(0.8)
        } else {
            switch type {
            case .clear:
                return Color.gray.opacity(0.2)
            case .load, .copy:
                return Color.gray
            case .submit:
                return Color.blue
            case .execute:
                return Color.orange
            case .delete:
                return Color.red
            }
        }
    }

    private var foregroundColor: Color {
        if isCanceling {
            return Color.white
        } else {
            switch type {
            case .clear, .load, .copy:
                return Color.primary
            case .execute:
                return Color.black
            case .submit, .delete:
                return Color.white
            }
        }
    }

    private var imageSystemName: String {
        if isCanceling {
            return "xmark.circle.fill"
        } else {
            switch type {
            case .copy:
                return "document.on.document"
            case .clear:
                return "xmark.circle"
            case .load:
                return "square.and.arrow.down.on.square"
            case .submit:
                return "paperplane.fill"
            case .execute:
                return "apple.terminal"
            case .delete:
                return "trash.fill"
            }
        }
    }

    private var dynamicTitle: String {
        isCanceling ? ( cancelTitle ?? "Cancel \(title)" ) : title
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: imageSystemName)
                    .font(.headline)
                    .accessibilityHidden(true)

                Text(dynamicTitle)
                    .font(.subheadline)
                    .bold()
            }
            .foregroundColor(foregroundColor)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(buttonColor)
            .cornerRadius(8)
            .scaleEffect(isPressed ? 0.90 : 1.0)
            .opacity(isEnabled ? 1 : 0.4)
            .animation(.easeInOut(duration: animationDuration), value: isPressed)

            .background(GeometryReader { geo in
                Color.clear
                    .onAppear { buttonSize = geo.size }
            })

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .allowsHitTesting(isEnabled)
        .gesture(
            DragGesture(minimumDistance: 0)
            .onChanged { value in
                let inside = value.location.x >= 0 &&
                             value.location.y >= 0 &&
                             value.location.x <= buttonSize.width &&
                             value.location.y <= buttonSize.height

                withAnimation(.easeInOut(duration: animationDuration)) {
                    isPressed = inside
                    isCanceling = !inside
                }
            }
            .onEnded { value in
                let inside = value.location.x >= 0 &&
                             value.location.y >= 0 &&
                             value.location.x <= buttonSize.width &&
                             value.location.y <= buttonSize.height

                withAnimation(.easeInOut(duration: animationDuration)) {
                    isPressed = false
                    isCanceling = false
                }

                if inside {
                    action()
                }
            }
        )
    }
}
