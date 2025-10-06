import Foundation

extension String {
    public func trimTrailing() -> String {
        return self.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }

    @inlinable
    public func dropFirstOccurrence(of substring: String) -> String {
        guard let range = range(of: substring) else { return self }
        var copy = self
        copy.removeSubrange(range)
        return copy
    }

    @inlinable
    public func dropLeading(_ string: String) -> String {
        if self.hasPrefix(string) { 
            return String(self.dropFirst(string.count)) 
        } else { 
            return self
        }
    }

    @inlinable
    public func dropTrailing(_ string: String) -> String {
        if self.hasSuffix(string) { 
            return String(self.dropLast(string.count)) 
        } else { 
            return self
        }
    }

    public func dropLeadingWhitespace() -> String {
        return dropLeading(" ")
    }

    public func dropTrailingWhitespace() -> String {
        return dropTrailing(" ")
    }

    public func dropLeadingNewline() -> String {
        return dropLeading("\n")
    }

    public func dropTrailingNewline() -> String {
        return dropTrailing("\n")
    }

    public func dropLeadingAndTrailing(_ string: String) -> String {
        return self
            .dropLeading(string)
            .dropTrailing(string)
    }

    public func dropLeadingAndTrailingWhitespace() -> String {
        let string = " "
        return self
            .dropLeading(string)
            .dropTrailing(string)
    }

    public func dropLeadingAndTrailingNewline() -> String {
        let string = "\n"
        return self
            .dropLeading(string)
            .dropTrailing(string)
    }

    public func dropLeadingAndTrailingNewlineAndWhitespace() -> String {
        return self
            .dropLeadingAndTrailingNewline()
            .dropLeadingAndTrailingWhitespace()
    }
}
