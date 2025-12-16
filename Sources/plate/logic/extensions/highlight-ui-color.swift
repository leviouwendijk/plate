import Foundation
import SwiftUI

extension String {
    public func highlighted(
        _ tokens: [String], 
        highlightColor: Color = .accentColor
        // baseFont: Font = .body
    ) -> AttributedString {
        var attr = AttributedString(self)
        let lower = self.lowercased()
        for token in tokens {
            var start = lower.startIndex
            while let range = lower[start...].range(of: token) {
                let nsRange = NSRange(range, in: self)
                if let swiftRange = Range(nsRange, in: attr) {
                    attr[swiftRange].foregroundColor = highlightColor
                    // attr[swiftRange].font = .bold()
                }
                start = range.upperBound
            }
        }
        return attr
    }
}
