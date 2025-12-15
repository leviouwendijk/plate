import Foundation

prefix operator ++
postfix operator ++

// Prefix: ++x  (increment, then return new value)
@discardableResult
prefix func ++ <T: FixedWidthInteger>(x: inout T) -> T {
    x += 1
    return x
}

// Postfix: x++ (return old value, then increment)
@discardableResult
postfix func ++ <T: FixedWidthInteger>(x: inout T) -> T {
    defer { x += 1 }
    return x
}
