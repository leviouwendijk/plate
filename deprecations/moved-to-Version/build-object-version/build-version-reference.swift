import Foundation

public enum VersionReference: String, RawRepresentable, Codable, CaseIterable, Sendable {
    // case built
    // case repository

    case compiled // for compiled.pkl
    case release // for build-object.pkl
}
