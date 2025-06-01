import Foundation

public protocol StringRemovable {
    func rm(_ stringsToRemove: String...) -> String
    func rmn(_ stringsToRemove: String...) -> String
}

extension String: StringRemovable {
    public func rm(_ stringsToRemove: String...) -> String { // removes string without normalizing inputs
        return stringsToRemove.reduce(self) { currentString, stringToRemove in
            currentString.replacingOccurrences(of: stringToRemove, with: "")
        }
    }
    
    public func rmn(_ stringsToRemove: String...) -> String { // removes string but normalizes inputs first
        let normalizedString = self.lowercased()
        return stringsToRemove.reduce(normalizedString) { currentString, stringToRemove in 
            currentString.replacingOccurrences(of: stringToRemove.lowercased(), with: "")
        }
    }
}

public protocol StringReplaceable {
    func rp(_ replacements: (String, String)...) -> String
    func rpn(_ replacements: (String, String)...) -> String
}

extension String: StringReplaceable {
    public func rp(_ replacements: (String, String)...) -> String {
        return replacements.reduce(self) { currentString, replacementPair in
            let (stringToReplace, stringToInsert) = replacementPair
            return currentString.replacingOccurrences(of: stringToReplace, with: stringToInsert)
        }
    }
    
    public func rpn(_ replacements: (String, String)...) -> String {
        let normalizedSelf = self.lowercased()
        return replacements.reduce(normalizedSelf) { currentString, replacementPair in
            let (stringToReplace, stringToInsert) = replacementPair
            return currentString.replacingOccurrences(of: stringToReplace.lowercased(), with: stringToInsert)
        }
    }
}
