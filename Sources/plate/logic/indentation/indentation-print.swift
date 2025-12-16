import Foundation

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
