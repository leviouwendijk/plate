import Foundation

public protocol EnvironmentResolvable: Sendable {
    func get(_ name: String) throws -> String
    // func infer(_ string: String) -> String
}
