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
    // case versionPrefix
    case latestVersion
}

// public enum VersionPrefixDisplayStyle {
//     case short
//     case long
// }

public struct BuildInformationStatic: View {
    public let specification: BuildSpecification
    public let alignment: AlignmentStyle
    public let display: [BuildInformationDisplayComponents]
    public let prefixStyle: VersionPrefixStyle

    @State private var isUpdateAvailable: Bool = false

    // remove hardcoding this
    public static let repoPkl = URL(string: "https://raw.githubusercontent.com/leviouwendijk/Responder/refs/heads/master/build-object.pkl")!

    public init(
        specification: BuildSpecification,
        alignment: AlignmentStyle = .center,
        display: [BuildInformationDisplayComponents] = [.version],
        prefixStyle: VersionPrefixStyle = .short
    ) {
        self.specification = specification
        self.alignment = alignment
        self.display = display
        self.prefixStyle = prefixStyle
    }

    // public var finalVersionString: String {
    //     var v = ""
    //     let prefix = prefixStyle == .short ? "v " : "version "
    //     if display.contains(.versionPrefix) { 
    //         v.append(prefix)
    //     }
    //     v.append(specification.versionString())
    //     return v
    // }
    
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
                    Text("deprecated")
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
    // public let specification: BuildSpecification
    public let localBuild: BuildObjectConfiguration
    public let alignment: AlignmentStyle
    public let display: [[BuildInformationDisplayComponents]]
    public let prefixStyle: VersionPrefixStyle

    @State public var current: Int = 0

    @State public var remoteBuild: BuildObjectConfiguration

    @State private var isUpdateAvailable: Bool = false
    @State private var updateError: String = ""

    public init(
        // specification: BuildSpecification = defaultBuildObject(),
        localBuild: BuildObjectConfiguration = defaultBuildObject(),
        alignment: AlignmentStyle = .center,
        display: [[BuildInformationDisplayComponents]] = [[.version], [.latestVersion], [.name], [.author]],
        prefixStyle: VersionPrefixStyle = .long
    ) {
        // self.specification = specification
        self.localBuild = localBuild
        self.remoteBuild = localBuild
        self.alignment = alignment
        self.display = display
        self.prefixStyle = prefixStyle
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
                            Text(localBuild.name)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        if display[current].contains(.version) {
                            VStack {
                                if !(updateError.isEmpty) {
                                    NotificationBanner(
                                        type: .error,
                                        message: updateError
                                    )
                                }

                                HStack {
                                    Text(localBuild.version.string(prefixStyle: prefixStyle))
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .strikethrough(isUpdateAvailable)

                                    if isUpdateAvailable {
                                        Text("update available (\(remoteBuild.version.string(prefixStyle: prefixStyle)))")
                                        .font(.footnote)
                                        // .fontWeight(.semibold)
                                        .foregroundColor(Color.orange)
                                    }
                                }
                            }
                        }

                        if display[current].contains(.latestVersion) {
                            VStack {
                                if !(updateError.isEmpty) {
                                    NotificationBanner(
                                        type: .error,
                                        message: updateError
                                    )
                                }

                                HStack {
                                    Text(remoteBuild.version.string(prefixStyle: prefixStyle, remote: true))
                                        .font(.footnote)
                                        .foregroundColor(.secondary)

                                    if isUpdateAvailable {
                                        Text("update available")
                                        .font(.footnote)
                                        // .fontWeight(.semibold)
                                        .foregroundColor(Color.orange)
                                    }
                                }
                            }
                        }

                        if display[current].contains(.author) {
                            Text(localBuild.author)
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
        .task {
            do {
                let fetched = try await fetchRemoteBuildObject()
                remoteBuild = fetched
                isUpdateAvailable = fetched.version > localBuild.version
            } catch {
                if let pklErr = error as? PklParserError {
                    updateError = pklErr.description
                } else {
                    updateError = error.localizedDescription
                }
            }
        }
    }
}

public func defaultBuildObject() -> BuildObjectConfiguration {
    do {
        return try BuildObjectConfiguration()
    } catch {
        print("PKL parse failed in BuildInformationSwitch:", error)
        return BuildObjectConfiguration(
            name: "",
            type: .application,
            version: ObjectVersion(major: 0, minor: 0, patch: 0),
            details: "",
            author: "",
            update: ""
        )
    }
}

enum UpdateCheckError: Error, LocalizedError {
    case missingUpdateURL
    case invalidUpdateURL(String)
    case networkFailure(Error)
    case remoteParseFailure(Error)

    var errorDescription: String? {
        switch self {
            case .missingUpdateURL:
                return "PKL is missing the `update` URL."
            case .invalidUpdateURL(let str):
                return "Invalid update URL in PKL: \(str)"
            case .networkFailure(let err):
                return "Network error: \(err.localizedDescription)"
            case .remoteParseFailure(let err):
                return "Failed to parse remote build-object: \(err)"
        }
    }
}

public func fetchRemoteBuildObject() async throws -> BuildObjectConfiguration {
    let localURL = try BuildObjectConfiguration.traverseForBuildObjectPkl(buildFile: "build-object.pkl")
    let localCfg = try BuildObjectConfiguration.parse(from: localURL)
    let updateString = localCfg.update

    guard let remoteURL = URL(string: updateString)
    else {
        throw UpdateCheckError.invalidUpdateURL(localCfg.update)
    }
    
    let request = URLRequest(url: remoteURL)
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let http = response as? HTTPURLResponse,
          http.statusCode == 200
    else {
        let code = (response as? HTTPURLResponse)?.statusCode ?? -1
        let networkErr = NSError(
            domain: "ResponderApp.UpdateCheck",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: "HTTP request failed with status code \(code)"]
        )
        throw UpdateCheckError.networkFailure(networkErr)
    }
    
    guard let text = String(data: data, encoding: .utf8) else {
        throw UpdateCheckError.remoteParseFailure(
            NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid UTF-8 data"])
        )
    }
    
    return try PklParser(text).parseBuildObject()
}
