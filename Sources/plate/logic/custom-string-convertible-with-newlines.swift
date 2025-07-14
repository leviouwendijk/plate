import Foundation

extension Array where Element: CustomStringConvertible {
    public func descriptionWithNewlines() -> String {
        self.map { $0.description }.joined(separator: "\n")
    }
}
