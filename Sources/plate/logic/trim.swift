import Foundation

extension String {
    public func trimTrailing() -> String {
        return self.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }

    public func dropFirstWhitespace() -> String {
        if self.hasPrefix(" ") { 
            return String(self.dropFirst()) 
        } else { 
            return self
        }
    }

    public func dropLastWhitespace() -> String {
        if self.hasSuffix(" ") { 
            return String(self.dropFirst()) 
        } else { 
            return self
        }
    }

    public func dropFirstAndLastWhitespace() -> String {
        return self
            .dropFirstWhitespace()
            .dropLastWhitespace()
    }
}
