import Foundation
import SwiftUI

extension String {
    public func wrapJsonForCLI() -> String {
        return "'[\(self)]'"
    }

    public func clipboard() -> Void {
        copyToClipboard(self)
    }

    public func replaceSimplePlaceholders(with values: [String: String]) -> String {
        var replaced = ""
        for (placeholder, value) in values {
            replaced = self.replacingOccurrences(of: placeholder, with: value)
        }
        return replaced
    }
}

extension View {
    @ViewBuilder
    public func hide(when hideCondition: Bool) -> some View {
        if hideCondition {
            self.hidden()
        } else {
            self
        }
    }
}
