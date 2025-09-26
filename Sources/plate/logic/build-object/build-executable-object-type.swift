import Foundation

public enum ExecutableObjectType: String, RawRepresentable, Codable, Sendable {
    case binary
    case application
    case script
    case specification
    case resource
}
