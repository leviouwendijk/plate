import Foundation

public enum Alignment {
    case left
    case right
}

public protocol Alignable {
    func align(_ side: Alignment,_ width: Int,_ char: String) -> String
}

extension String: Alignable {
    // example use -> "This is a string".align(.left, 50)
    public func align(_ side: Alignment,_ width: Int = 80,_ char: String = ".") -> String {
        let padding = max(0, width - self.count)

        switch side {
        case .left:
            let paddedText = self + String(repeating: char, count: padding)
            return paddedText
        case .right:
            let paddedText = String(repeating: char, count: padding) + self
            return paddedText
        }
    }
}

public func optimalWidth(for pairs: [(String, String)], spaceBetween: Int = 10) -> Int {
    let maxPairLength = pairs
        .map { $0.0.count + $0.1.count }
        .max() ?? 0
    return maxPairLength + spaceBetween
}

public func align(
    left: String,
    right: String,
    width: Int = 80,
    char: String = " ",
    spaceBetween: Int = 10
) -> String {
    let total = left.count + right.count
    let effectiveWidth = total > width ? total + spaceBetween : width
    let middle = max(0, effectiveWidth - total)
    let fill = String(repeating: char, count: middle)
    return left + fill + right
}

public func alignPairs(
    pairs: [(String, String)],
    spaceBetween: Int = 10,
    char: String = " "
) -> [String] {
    let width = optimalWidth(for: pairs, spaceBetween: spaceBetween)
    return pairs.map { l, r in
        align(left: l, right: r, width: width, char: char, spaceBetween: spaceBetween)
    }
}

extension Array where Element == (String, String) {
    public func aligned(
        spaceBetween: Int = 10,
        char: String = " "
    ) -> [String] {
        let width = optimalWidth(for: self, spaceBetween: spaceBetween)
        return self.map { l, r in
            align(left: l, right: r, width: width, char: char, spaceBetween: spaceBetween)
        }
    }
}
