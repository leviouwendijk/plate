// uses ANSI
import Foundation

public enum Selection {
    case first
    case all
    case varied
}

public protocol Capitalization {
    func capitalize(_ selection: Selection) -> String
}

extension String: Capitalization {
    public func capitalize(_ selection: Selection) -> String {
        let normalized = self.lowercased()
        let enArticles = ["of", "from", "the", "a", "an", "in", "on", "with"]
        let nlArticles = ["van", "de", "der", "den", "het", "een"]
        let articles = Set(enArticles + nlArticles)  // Combine English and Dutch articles


        switch selection {
            case .first: 
                return normalized.prefix(1).uppercased() + self.dropFirst()
            case .all: 
                return normalized.split(separator: " ").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
            case .varied:
                return normalized.split(separator: " ").enumerated().map { index, word in
                    let wordStr = String(word)  // Convert Substring to String
                    if index == 0 || !articles.contains(wordStr) { // Capitalize first word and non-articles
                        return wordStr.prefix(1).uppercased() + wordStr.dropFirst()
                    } else {
                        return wordStr  // Keep articles in lowercase
                    }
                }.joined(separator: " ")
        }
    }
}
