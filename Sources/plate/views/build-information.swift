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
    case versionPrefix
}

public enum VersionPrefixDisplayStyle {
    case short
    case long
}

public struct BuildInformationStatic: View {
    public let specification: BuildSpecification
    public let alignment: AlignmentStyle
    public let display: [BuildInformationDisplayComponents]
    public let prefixStyle: VersionPrefixDisplayStyle

    @State private var isUpdateAvailable: Bool = false

    // remove hardcoding this
    public static let repoPkl = URL(string: "https://raw.githubusercontent.com/leviouwendijk/Responder/refs/heads/master/build-object.pkl")!

    public init(
        specification: BuildSpecification,
        alignment: AlignmentStyle = .center,
        display: [BuildInformationDisplayComponents] = [.version],
        prefixStyle: VersionPrefixDisplayStyle = .short
    ) {
        self.specification = specification
        self.alignment = alignment
        self.display = display
        self.prefixStyle = prefixStyle
    }

    public var finalVersionString: String {
        var v = ""
        let prefix = prefixStyle == .short ? "v " : "version "
        if display.contains(.versionPrefix) { 
            v.append(prefix)
        }
        v.append(specification.versionString())
        return v
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
                    Text(finalVersionString)
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

public struct BuildInformationSwitch: View {
    public let specification: BuildSpecification
    public let alignment: AlignmentStyle
    public let display: [[BuildInformationDisplayComponents]]
    public let prefixStyle: VersionPrefixDisplayStyle

    @State public var current: Int = 0
    @State private var isUpdateAvailable: Bool = false

    // remove hardcoding this
    public static let repoPkl = URL(string: "https://raw.githubusercontent.com/leviouwendijk/Responder/refs/heads/master/build-object.pkl")!

    public init(
        specification: BuildSpecification = defaultBuildObject(),
        alignment: AlignmentStyle = .center,
        display: [[BuildInformationDisplayComponents]] = [[.version, .versionPrefix], [.name], [.author]],
        prefixStyle: VersionPrefixDisplayStyle = .short
    ) {
        self.specification = specification
        self.alignment = alignment
        self.display = display
        self.prefixStyle = prefixStyle
    }

    public var finalVersionString: String {
        var v = ""
        let prefix = prefixStyle == .short ? "v " : "version "
        if display[current].contains(.versionPrefix) { 
            v.append(prefix)
        }
        v.append(specification.versionString())
        return v
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                current = (current + 1) % display.count
            }
        }) {
            ZStack {
                HStack {
                    if alignment == .trailing { Spacer() }
                    VStack {
                        if display[current].contains(.name) {
                            Text(specification.name)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        if display[current].contains(.version) {
                            Text(finalVersionString)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        if display[current].contains(.author) {
                            Text(specification.author)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    if alignment == .leading { Spacer() }
                }
                .id(current)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom)
                                 .combined(with: .opacity),
                    removal:   .move(edge: .top)
                                 .combined(with: .opacity)
                ))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.1))
        }
        .buttonStyle(.plain)
    }
}

public func defaultBuildObject() -> BuildSpecification {
    do {
        return try BuildSpecification(fromPkl: URL(fileURLWithPath: "build-object.pkl"))
    } catch {
        print("PKL parse failed in BuildInformationSwitch:", error)
        return BuildSpecification(
            version: BuildVersion(major: 0, minor: 0, patch: 0),
            name: "", author: "", description: ""
        )
    }
}
