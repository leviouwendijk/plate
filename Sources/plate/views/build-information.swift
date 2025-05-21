import SwiftUI

public enum AlignmentStyle {
    case leading
    case trailing
    case center
}

public enum BuildInformationDisplayComponents {
    case version
    case name
    case author
    case description
}

public struct BuildInformation: View {
    public let specification: BuildSpecification
    public let alignment: AlignmentStyle
    public let display: [BuildInformationDisplayComponents]

    public init(
        specification: BuildSpecification,
        alignment: AlignmentStyle = .center,
        display: [BuildInformationDisplayComponents] = [.version]
    ) {
        self.specification = specification
        self.alignment = alignment
        self.display = display
    }
    
    public var body: some View {
        HStack {
            if alignment == .trailing {
                Spacer()
            }

            VStack {
                if display.contains(.name) {
                    Text(specification.name)
                    .font(.footnote).foregroundColor(.secondary)
                }
                
                if display.contains(.version) {
                    Text(specification.versionString())
                    .font(.footnote).foregroundColor(.secondary)
                }

                if display.contains(.author) {
                    Text(specification.author)
                    .font(.footnote).foregroundColor(.secondary)
                }
            }

            if alignment == .leading {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.1))
    }
}
