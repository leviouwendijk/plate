import Foundation

public enum Alignment {
    case left
    case right
}

public protocol Alignable {
    func align(_ side: Alignment,_ width: Int) -> String
}

extension String: Alignable {
    // example use -> "This is a string".align(.left, 50)
    public func align(_ side: Alignment,_ width: Int = 80) -> String {
        let padding = max(0, width - self.count)

        switch side {
        case .left:
            let paddedText = self + String(repeating: ".", count: padding)
            return paddedText
        case .right:
            let paddedText = String(repeating: ".", count: padding) + self
            return paddedText
        }
    }
}


