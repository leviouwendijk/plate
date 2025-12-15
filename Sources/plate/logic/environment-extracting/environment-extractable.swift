import Foundation

#if os(macOS)
public protocol EnvironmentExtractable: 
    EnvironmentResolvable,
    RawRepresentable,
    CaseIterable,
    Sendable,
    Hashable
    where RawValue == String {
        var key: EnvironmentExtractableKey { get }
        func infer() -> String
        // func get(_ key: String) throws -> String
}
#endif
