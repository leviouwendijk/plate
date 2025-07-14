import Foundation
import SwiftUI
import AppKit

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

    public func replaceVariable(
        replacing placeholder: String,
        with replacement: String
    ) -> String {
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

    public func strippingBreaks() -> String {
        return self.replacingOccurrences(of: "<br>", with: "")
    }

    public func strippingTrailingSlashes() -> String {
        var updated = self
        while updated.last == "/" {
            let new = updated.dropLast()
            updated = String(new)
        }
        return updated
    }

    public func strippingDomainProtocol() -> String {
        return self
        .replacingOccurrences(of: "http://", with: "")
        .replacingOccurrences(of: "https://", with: "")
    }

    public func strippingExtension(type: DocumentExtensionType) -> String {
        return self
        .replacingOccurrences(of: type.dotPrefixed, with: "")
    }

    public func appendingExtension(type: DocumentExtensionType) -> String {
        return self + type.dotPrefixed
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

public enum WrittenDateLocale: String, RawRepresentable {
    case us = "en_US"
    case nl = "nl_NL"
    case gb = "en_GB"
}

extension Date {
    /// e.g. “07/06/2025”
    public func conventional() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        return fmt.string(from: self)
    }

    /// e.g. “14:30”
    public func time() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: self)
    }

    /// e.g. “Monday, 7 June”
    public func written(
        in locale: WrittenDateLocale = .nl
    ) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: locale.rawValue)
        fmt.dateFormat = "EEEE, d MMMM"
        return fmt.string(from: self)
    }
}

public extension Font {
    static let tableLine = Font.system(size: 14, weight: .regular, design: .default)
}

extension NSAttributedString {
    public func justified() -> Self {
        let para = NSMutableParagraphStyle()
        para.alignment = .justified
        // para.lineSpacing = 4.0

        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: mutable.length))
        return type(of: self).init(attributedString: mutable)
    }

    public func withFontSize(_ fontSize: CGFloat) -> Self {
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.beginEditing()
        
        mutable.enumerateAttribute(
            .font,
            in: NSRange(location: 0, length: mutable.length),
            options: []
        ) { value, range, _ in
            let newFont: NSFont
            if let old = value as? NSFont,
                let replaced = NSFont(descriptor: old.fontDescriptor, size: fontSize) {
                   newFont = replaced
            } else {
                newFont = NSFont.systemFont(ofSize: fontSize)
            }
            mutable.addAttribute(.font, value: newFont, range: range)
        }
        
        mutable.endEditing()
        return type(of: self).init(attributedString: mutable)
    }

    public func withFont(_ font: NSFont) -> Self {
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.beginEditing()
        
        mutable.enumerateAttribute(
            .font, in: NSRange(location: 0, length: mutable.length), options: []) { _, range, _ in
            mutable.addAttribute(.font, value: font, range: range)
        }
        
        mutable.endEditing()
        return type(of: self).init(attributedString: mutable)
    }
}
