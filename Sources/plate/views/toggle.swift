import SwiftUI

public enum StandardToggleStyleType: CaseIterable {
    case checkbox
    case `switch`
}

public struct StandardToggle: View {
    public let style: StandardToggleStyleType
    @Binding public var isOn: Bool
    public let title: String
    public let subtitle: String?
    public let animationDuration: TimeInterval

    public init(
        style: StandardToggleStyleType = .checkbox,
        isOn: Binding<Bool>,
        title: String,
        subtitle: String? = nil,
        animationDuration: Double = 0.2
    ) {
        self.style = style
        self._isOn = isOn
        self.title = title
        self.subtitle = subtitle
        self.animationDuration = animationDuration
    }

    private var backgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.white
        #endif
    }

    public var body: some View {
        Group {
            switch style {
            case .checkbox:
                Button(action: {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        isOn.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isOn ? "checkmark.square.fill" : "square")
                            .font(.headline)
                            .foregroundColor(isOn ? .accentColor : .secondary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.subheadline)
                                .bold()
                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(backgroundColor)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())

            case .switch:
                Toggle(isOn: $isOn) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline)
                            .bold()
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .animation(.easeInOut(duration: animationDuration), value: isOn)
            }
        }
    }
}
