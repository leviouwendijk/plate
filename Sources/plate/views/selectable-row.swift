import Foundation
import SwiftUI

public struct SelectableRow: View {
    public let title: String
    public let isSelected: Bool
    public let action: () -> Void
    public let animationDuration: TimeInterval

    public init(
        title: String,
        isSelected: Bool,
        animationDuration: Double = 0.2,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.animationDuration = animationDuration
        self.action = action
    }

    public var body: some View {
        HStack {
            if isSelected {
                Text(title)
                    // .font(.headline)
                    // .foregroundColor(Color("NearBlack"))
                    .foregroundColor(Color.black)
                    // .bold()
            } else {
                Text(title)
                    // .font(.headline)
                    // .foregroundColor(Color("NearBlack"))
                    // .foregroundColor(isSelected ? Color.black : Color.secondary)
                    .foregroundColor(Color.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(
            isSelected
                ? Color.blue.opacity(0.3)
                : Color.clear
        )
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .shadow(
            color: isSelected ? Color.blue.opacity(0.1) : Color.white,
            radius: 5
        )
        .contentShape(RoundedRectangle(
            cornerRadius: 5
        ))
        .onTapGesture {
            withAnimation(.easeInOut(duration: animationDuration)) {
                action()
            }
            // action()
        }
    }
}
