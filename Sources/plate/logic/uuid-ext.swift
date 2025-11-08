import Foundation

extension UUID {
    public var noDashes: String {
        return self.uuidString.replacingOccurrences(of: "-", with: "")
    }

    public static func newNoDashString() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
