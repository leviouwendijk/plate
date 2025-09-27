import Foundation

extension BuildObjectConfiguration {
    public func nil_init() -> BuildObjectConfiguration {
        return .init(
            name: "",
            types: [],
            versions: ProjectVersions(
                release: ObjectVersion.default_version(for: .release)    
            ),
            compile: CompileInstructionDefaults(use: false, arguments: []),
            details: "",
            author: "",
            update: ""
        )
    }
}
