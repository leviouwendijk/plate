import Foundation

public func sametype<X, Y>(
    _ x: X.Type,
    _ y: Y.Type,
    verbose: Bool = false
) -> Bool {
    let result = (X.self == Y.self)
    if verbose {
        print("tYpe X ==", X.self)
        print("tYpe Y ==", Y.self)
        print("result:", result)
    }
    return result
}

public func anysametype(
    _ x: Any.Type,
    _ y: Any.Type,
    verbose: Bool = false
) -> Bool {
    let result = (x.self == y.self)
    if verbose {
        print("type x ==", x.self)
        print("type y ==", y.self)
        print("result:", result)
    }
    return result
}
