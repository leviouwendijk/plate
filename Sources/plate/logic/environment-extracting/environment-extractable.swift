import Foundation

public protocol EnvironmentExtractable: RawRepresentable, CaseIterable, Sendable, Hashable where RawValue == String {
    var key: EnvironmentExtractableKey { get }
    func infer() -> String
    func get(_ key: String) throws -> String
}


extension Collection where Element: EnvironmentExtractable {
    /// Validate a set of keys at once; returns `[Element: String]`.
    public func validate() throws -> [Element: String] {
        var out: [Element: String] = [:]
        out.reserveCapacity(self.count)
        for k in self {
            out[k] = try k.value()
        }
        return out
    }
}
