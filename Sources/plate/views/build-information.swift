import SwiftUI

public struct BuildInformation: View {
    public let specification: BuildSpecification

    public init(
        specification: BuildSpecification
    ) {
        self.specification = specification
    }
    
    public var body: some View {
        HStack {
            Text(specification.versionString())
                .font(.footnote).foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.1))
    }
}
