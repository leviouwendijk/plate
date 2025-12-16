import Foundation

extension String {
    public var asciiSearchNormalized: String {
        var s = self
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripCombiningMarks, reverse: false)
            ?? self

        let ligatures: [String: String] = [
            "ß": "ss", "Æ": "AE", "æ": "ae",
            "Œ": "OE", "œ": "oe"
        ]

        for (special, plain) in ligatures {
            s = s.replacingOccurrences(of: special, with: plain)
        }

        let dashChars = CharacterSet(charactersIn: "–—−-") // en, em, minus, non-break
        s = s.components(separatedBy: dashChars).joined(separator: "-")

        let punct = CharacterSet.punctuationCharacters
        s = s.components(separatedBy: punct).joined(separator: " ")

        let comps = s
            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return comps.joined(separator: " ").lowercased()
    }
}
