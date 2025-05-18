import Foundation

extension String {
    public func wrapJsonForCLI() -> String {
        return "'[\(self)]'"
    }
}
