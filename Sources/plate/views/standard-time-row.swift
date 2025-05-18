import SwiftUI

public struct StandardTimeRow: View {
    let title: String?
    @Binding var start: Date
    @Binding var end: Date

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
        title: String? = nil,
        start: Binding<Date>,
        end: Binding<Date>
    ) {
        self.title = title
        self._start = start
        self._end = end
    }

    public var body: some View {
        VStack() {
            if let t = title {
                Text(t)
                    .font(.subheadline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                TimePickerBinding(date: $start)
                TimePickerBinding(date: $end)
            }
        }
        .padding(4)
        .background(backgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    private struct TimePickerBinding: View {
        @Binding var date: Date
        var body: some View {
            HStack {
                Image(systemName: "clock")
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(6)
        }
    }
}
