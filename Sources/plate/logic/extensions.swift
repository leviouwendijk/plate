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

    public func strippingExportPrefix() -> String {
        let prefix = "export "
        if self.hasPrefix(prefix) {
            return String(self.dropFirst(prefix.count))
        }
        return self
    }
    
    public func strippingEnclosingQuotes() -> String {
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

    public func strippingUnderscores() -> String {
        return self.replacingOccurrences(of: "_", with: "")
    }

    public func strippingDots() -> String {
        return self.replacingOccurrences(of: ".", with: "")
    }

    public func strippingCommas() -> String {
        return self.replacingOccurrences(of: ",", with: "")
    }

    public func cleanedNumberInput() -> String {
        return self
        .strippingUnderscores()
        .strippingDots()
        .strippingCommas()
    }
}

extension Double {
    public func display(
        decimals: Int = 2,
        thousandsSeparator: String? = ",",
        decimalSeparator: String? = ".",

    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if let thousands = thousandsSeparator {
            formatter.groupingSeparator = thousands
        }

        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals

        if let decim = decimalSeparator {
            formatter.decimalSeparator = decim
        }

        let number = NSNumber(value: self)
        return formatter.string(from: number) ?? "n/a (plate/extensions)"
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
