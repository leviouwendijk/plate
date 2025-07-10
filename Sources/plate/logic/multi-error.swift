import Foundation

public struct MultiError: Error, Sendable {
    public let errors: [Error]
    public init(_ errors: [Error]) {
        self.errors = errors
    }
}
