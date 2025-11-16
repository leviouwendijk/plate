extension Optional {
    public var isNil: Bool { self == nil }
}

// public func all_nil<T>(_ values: [T?]) -> Bool {
//     return values.allSatisfy { $0.isNil }
// }

// public func all_nil<T>(_ values: T?...) -> Bool {
//     return values.allSatisfy { $0.isNil }
// }

public func all_nil(_ values: [Any?]) -> Bool {
    return values.compactMap { $0 }.isEmpty
}

extension Array where Element == Any {
    public var allNil: Bool {
        return plate.all_nil(self)
    }
}

extension Array where Element == Any? {
    public var allNil: Bool {
        return plate.all_nil(self)
    }
}
