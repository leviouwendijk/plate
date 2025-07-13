import Foundation

public protocol StringIndentable {
    func indent(_ indentation: Int, times: Int) -> String
}

extension String: StringIndentable {
    public func indent(_ indentation: Int = 4, times: Int = 1) -> String { 
        let spaces = indentation * times
        let indent = String(repeating: " ", count: spaces)

        return self
            .split(separator: "\n")
            .map { "\(indent)\($0)" }
            .joined(separator: "\n")
    }
}

