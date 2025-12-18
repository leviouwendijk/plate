import Foundation

public func indentation(size: Int = 4, times: Int = 1) -> String {
    return String(repeating: " ", count: (size * times))
}
