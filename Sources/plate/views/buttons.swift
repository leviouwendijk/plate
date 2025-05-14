import Foundation
import SwiftUI

public enum StandardButtonType: String, CaseIterable {
    case clear    // clear a field
    case load    // load data
    case submit   // submit
    case execute  // execute a process
    case delete   // delete or remove something
}

public struct StandardButton: View {
    public let type: StandardButtonType
    public let title: String
    public let subtitle: String
    public let action: () -> Void
    public let animationDuration: TimeInterval

    @State private var isPressed: Bool = false
    @Environment(\.isEnabled) private var isEnabled: Bool

    public init(
        type: StandardButtonType,
        title: String,
        subtitle: String = "",
        animationDuration: Double = 0.2,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.animationDuration = animationDuration
        self.action = action
    }

    private var buttonColor: Color {
        switch type {
        case .clear:
            return Color.gray.opacity(0.2)
        case .load:
            return Color.gray
        case .submit:
            return Color.blue
        case .execute:
            return Color.orange
        case .delete:
            return Color.red
        }
    }

    private var foregroundColor: Color {
        switch type {
        case .clear, .load:
            return Color.primary
        case .execute:
            return Color.black
        case .submit, .delete:
            return Color.white
        }
    }

    private var imageSystemName: String {
        switch type {
        case .clear:
            return "xmark.circle"
        case .load:
            return "square.and.arrow.down.on.square"
        case .submit:
            return "paperplane.fill"
        case .execute:
            return "play.circle.fill"
        case .delete:
            return "trash.fill"
        }
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: imageSystemName)
                    .font(.headline)
                    .accessibilityHidden(true)

                Text(title)
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
            .onChanged { _ in
                withAnimation(.easeInOut(duration: animationDuration)) {
                    isPressed = true
                }
            }
            .onEnded { _ in
                withAnimation(.easeInOut(duration: animationDuration)) {
                    isPressed = false
                }
                action()
            }
        )
    }
}
