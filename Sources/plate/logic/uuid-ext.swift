import Foundation

extension UUID {
    var noDashes: String {
        return self.uuidString.replacingOccurrences(of: "-", with: "")
    }

    static func newNoDashString() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
