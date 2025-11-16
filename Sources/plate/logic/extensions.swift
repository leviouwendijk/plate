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

    public func appendingNewline() -> String {
        return self + "\n"
    }

    public func underscoresToHyphens() -> String {
        return self
        .replacingOccurrences(of: "_", with: "-")
    }

    public func strippingHtmlWidthAttributes() -> String {
        return self
        .replacingOccurrences(
            of: #"width="\{\{.+?\}\}"#, 
            with: "",
            options: .regularExpression
        )
        .trimmingCharacters(in: CharacterSet.whitespaces)
    }

    public var normKey: String {
        self.replacingOccurrences(of: "\u{00A0}", with: " ")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var esc: String { 
        self.replacingOccurrences(of: "\"", with: "\\\"") 
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

    public func applyingFontTransform(_ transform: (NSFont) -> NSFont) -> Self {
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.beginEditing()
        
        mutable.enumerateAttribute(.font, in: NSRange(location: 0, length: mutable.length), options: []) { value, range, _ in
            let oldFont = (value as? NSFont) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let newFont = transform(oldFont)
            mutable.addAttribute(.font, value: newFont, range: range)
        }
        
        mutable.endEditing()
        return type(of: self).init(attributedString: mutable)
    }

    public func withFontSize(_ fontSize: CGFloat) -> Self {
        return applyingFontTransform { oldFont in
            return NSFont(descriptor: oldFont.fontDescriptor, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        }
    }

    public func withFont(_ baseFont: NSFont) -> Self {
        let manager = NSFontManager.shared
        return applyingFontTransform { oldFont in
            let traits = oldFont.fontDescriptor.symbolicTraits
            var newFont = NSFont(descriptor: baseFont.fontDescriptor, size: baseFont.pointSize) ?? baseFont

            if traits.contains(.italic)      { newFont = manager.convert(newFont, toHaveTrait: .italicFontMask) }
            if traits.contains(.bold)        { newFont = manager.convert(newFont, toHaveTrait: .boldFontMask) }
            if traits.contains(.condensed)   { newFont = manager.convert(newFont, toHaveTrait: .condensedFontMask) }
            if traits.contains(.expanded)    { newFont = manager.convert(newFont, toHaveTrait: .expandedFontMask) }
            // if traits.contains(.monoSpace)   { newFont = manager.convert(newFont, toHaveTrait: .monospacedFontMask) }
            // if traits.contains(.vertical)    { newFont = manager.convert(newFont, toHaveTrait: .verticalFontMask) }
            // if traits.contains(.uiOptimized) { newFont = manager.convert(newFont, toHaveTrait: .uiOptimizedFontMask) }
            // if traits.contains(.tightLeading){ newFont = manager.convert(newFont, toHaveTrait: .tightLeadingFontMask) }
            // if traits.contains(.looseLeading){ newFont = manager.convert(newFont, toHaveTrait: .looseLeadingFontMask) }
            // if traits.contains(.colorGlyphs) { newFont = manager.convert(newFont, toHaveTrait: .colorGlyphsFontMask) }
            // if traits.contains(.composite)   { newFont = manager.convert(newFont, toHaveTrait: .compositeFontMask) }

            return newFont
        }
    }

    public func withFont(name: String, size: CGFloat) -> Self {
        let baseFont = NSFont(name: name, size: size) ?? NSFont.systemFont(ofSize: size, weight: .regular)
        return withFont(baseFont)
    }
}
