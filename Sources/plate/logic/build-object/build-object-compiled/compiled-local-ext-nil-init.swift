import Foundation

extension CompiledLocalBuildObject {
    public func nil_init() -> CompiledLocalBuildObject {
        return .init(
            version: ObjectVersion.default_version(for: .compiled),
            arguments: []
        )
    }
}
