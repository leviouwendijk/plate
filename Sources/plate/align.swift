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


