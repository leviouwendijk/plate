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
    public let width: CGFloat
    public let animationDuration: TimeInterval

    private var backgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.white
        #endif
    }

    public init(
        style: StandardToggleStyleType = .checkbox,
        isOn: Binding<Bool>,
        title: String,
        subtitle: String? = nil,
        width: CGFloat = 50,
        animationDuration: Double = 0.2
    ) {
        self.style = style
        self._isOn = isOn
        self.title = title
        self.subtitle = subtitle
        self.width = width
        self.animationDuration = animationDuration
    }

    @ViewBuilder
    public var body: some View {
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
            }
            .buttonStyle(PlainButtonStyle())
            .background(backgroundColor)
            .cornerRadius(8)

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
            .background(backgroundColor)
            .cornerRadius(8)
            .frame(minWidth: width)
            .animation(.easeInOut(duration: animationDuration), value: isOn)
        }
    }
}
