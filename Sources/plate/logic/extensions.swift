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
        var modifiedTemplate = self
        for (placeholder, value) in values {
            modifiedTemplate = modifiedTemplate.replacingOccurrences(of: placeholder, with: value)
        }
        return modifiedTemplate
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
