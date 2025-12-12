import Foundation

public func sametype<X, Y>(_ x: X.Type,_ y: Y.Type) -> Bool {
    return X.self == Y.self
}

public func anysametype(_ x: Any.Type,_ y: Any.Type) -> Bool {
    return x.self == y.self
}
