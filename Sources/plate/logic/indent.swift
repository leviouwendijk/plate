import Foundation

public struct StandardIndentation: Sendable {
    public static let size: Int = 4
    public static let times: Int = 1
}

public protocol StringIndentable {
    func indent(_ indentation: Int, times: Int) -> String
}

extension String: StringIndentable {
    public func indent(_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> String { 
        let spaces = indentation * times
        let indent = String(repeating: " ", count: spaces)

        return self
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { "\(indent)\($0)" }
            .joined(separator: "\n")
    }
}

// convenience func
public func printi(_ s: String,_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
    print(s.indent(indentation, times: times))
}

public func printindent(_ s: String,_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
    printi(s, indentation, times: times)
}

public func prindent(_ s: String,_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
    printi(s, indentation, times: times)
}

public func printdent(_ s: String,_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
    printi(s, indentation, times: times)
}

// extension mirror
extension String {
    public func printi(_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
        plate.printi(self, indentation, times: times)
    }

    public func printindent(_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
        plate.printi(self, indentation, times: times)
    }

    public func prindent(_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
        plate.printi(self, indentation, times: times)
    }

    public func printdent(_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
        plate.printi(self, indentation, times: times)
    }
}
