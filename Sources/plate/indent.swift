import Foundation

public protocol StringIndentable {
    func indent(_ indentation: Int) -> String
}

extension String: StringIndentable {
    public func indent(_ indentation: Int = 4) -> String { 
        let indent = String(repeating: " ", count: indentation)

        return self
            .split(separator: "\n") // Split the string into lines
            .map { "\(indent)\($0)" } // Add indentation to each line
            .joined(separator: "\n") // Combine lines back into a single string
    }
}

