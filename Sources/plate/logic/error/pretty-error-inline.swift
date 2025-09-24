import Foundation

public protocol PrettyError: Error {
    func formatted() -> String
}

public extension Error {
    func pretty() -> String {
        if let p = self as? (any PrettyError) {
            return p.formatted()
        }
        return "✖ \(localizedDescription)".ansi(.red)
    }
}
