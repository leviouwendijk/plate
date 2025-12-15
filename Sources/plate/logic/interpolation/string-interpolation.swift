import Foundation

extension String.StringInterpolation {
    public mutating func appendInterpolation<T>(orNil: T?, src: String? = nil) {
        if let value = orNil {
            appendInterpolation(value)
        } else {
            var literal = "nil"
            if let src {
                literal.append(" (source: ")
                literal.append(src)
                literal.append(")")
            }
            appendLiteral(literal)
        }
    }
}
