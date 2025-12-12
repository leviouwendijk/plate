import Foundation

public func sametype<X, Y>(_ x: X.Type,_ y: Y.Type) -> Bool {
    return X.self == Y.self
}
