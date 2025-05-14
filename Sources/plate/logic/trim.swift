import Foundation

extension String {
    public func trimTrailing() -> String {
        return self.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }
}
