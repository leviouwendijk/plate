import Foundation
import SwiftUI

extension String {
    public func wrapJsonForCLI() -> String {
        return "'[\(self)]'"
    }

    public func clipboard() -> Void {
        copyToClipboard(self)
    }

    public func replaceNotEmptyVariable(
        replacing placeholder: String,
        with replacement: String
    ) -> String {
        guard !replacement.isEmpty else {
            return self
        }
        return self.replacingOccurrences(of: placeholder, with: replacement)
    }

    public func replaceSimplePlaceholders(with values: [String: String]) -> String {
        var replaced = ""
        for (placeholder, value) in values {
            replaced = self.replacingOccurrences(of: placeholder, with: value)
        }
        return replaced
    }

    public func replacingShellHomeVariable() -> String {
        let home = Home.string()
        return self.replacingOccurrences(of: "$HOME", with: home)
    }

    func strippingExportPrefix() -> String {
        let prefix = "export "
        if self.hasPrefix(prefix) {
            return String(self.dropFirst(prefix.count))
        }
        return self
    }
    
    func strippingEnclosingQuotes() -> String {
        guard self.count >= 2 else {
            return self
        }
        let firstChar = self.first!
        let lastChar = self.last!
        
        if (firstChar == "\"" && lastChar == "\"") || (firstChar == "'" && lastChar == "'") {
            return String(self.dropFirst().dropLast())
        }
        return self
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
