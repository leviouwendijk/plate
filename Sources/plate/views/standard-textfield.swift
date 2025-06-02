import Foundation
import SwiftUI

public struct StandardTextField: View {
    /// The label shown above the field (also used for accessibility).
    public let label: String
    /// A light hint shown inside when the text is empty.
    public let placeholder: String?
    /// A small helper / error message below the field.
    public let helperText: String?
    /// Optional SF Symbol to show on the left.
    public let icon: String?
    /// Maximum width (nil = flexible).
    public let maxWidth: CGFloat?
    public let validation: ValidationType?

    @Binding public var text: String
    @FocusState private var isFocused: Bool
    @State private var validationMessage: String?

    public init(
        _ label: String,
        text: Binding<String>,
        placeholder: String? = nil,
        helperText: String? = nil,
        icon: String? = nil,
        maxWidth: CGFloat? = nil,
        validation: ValidationType? = nil
    ) {
        self.label               = label
        self._text               = text
        self.placeholder         = placeholder
        self.helperText          = helperText
        self.icon                = icon
        self.maxWidth            = maxWidth
        self.validation = validation
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)

            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.secondary)
                }

                ZStack(alignment: .leading) {
                    if text.isEmpty, let placeholder {
                        Text(placeholder)
                            .foregroundColor(.secondary)
                            .padding(.leading, 1)
                    }
                    TextField("", text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused($isFocused)
                        // .onChange(of: text) { newValue in
                        //     validate(newValue)
                        // }
                        .onSubmit {
                          validate(text)
                        }
                }

                // if !text.isEmpty {
                //     Button { text = "" }
                //     label: { Image(systemName: "xmark.circle.fill") }
                // }

                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .opacity(text.isEmpty ? 0 : 1)
                }
                .disabled(text.isEmpty)
                .opacity(text.isEmpty ? 0 : 1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )

            if let msg = validationMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: maxWidth)
        .animation(.easeInOut, value: validationMessage)
        .onAppear { validate(text) }
    }

    private var borderColor: Color {
        if isFocused { return .accentColor }
        if let _ = validation, let msg = validationMessage, !msg.isEmpty {
            return .red
        }
        return .gray
    }

    private func validate(_ input: String) {
        guard let validation = validation, !input.isEmpty else {
            validationMessage = nil
            return
        }
        let result = validation.validate(input)
        validationMessage = result.message
    }
}

public enum ValidationType {
    case email
    case phone
    case custom((String) -> Bool, errorMessage: String)

    public func validate(_ input: String) -> (isValid: Bool, message: String?) {
        switch self {
        case .email:
            let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
            let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let range = NSRange(input.startIndex..., in: input)
            let match = regex.firstMatch(in: input, options: [], range: range) != nil
            return (match, match ? nil : "Invalid email format")
        case .phone:
            let filtered = input.filter { "+0123456789 -()".contains($0) }
            let isValid = filtered.count >= 7 && filtered.count <= 15
            return (isValid, isValid ? nil : "Invalid phone number")
        case .custom(let rule, let errorMessage):
            let ok = rule(input)
            return (ok, ok ? nil : errorMessage)
        }
    }
}
