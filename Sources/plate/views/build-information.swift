import SwiftUI

public enum AlignmentStyle {
    case leading
    case trailing
    case center
}

public struct BuildInformation: View {
    public let specification: BuildSpecification
    public let alignment: AlignmentStyle

    public init(
        specification: BuildSpecification,
        alignment: AlignmentStyle = .center
    ) {
        self.specification = specification
        self.alignment = alignment
    }
    
    public var body: some View {
        HStack {
            if alignment == .trailing {
                Spacer()
            }

            Text(specification.versionString())
                .font(.footnote).foregroundColor(.secondary)

            if alignment == .leading {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.1))
    }
}
