extension Optional {
    public var isNil: Bool { self == nil }
}

public func all_nil<T>(_ values: [T?]) -> Bool {
    return values.allSatisfy { $0.isNil }
}

public func all_nil<T>(_ values: T?...) -> Bool {
    return values.allSatisfy { $0.isNil }
}

extension Array where Element: ExpressibleByNilLiteral {
    public var allNil: Bool { return plate.all_nil(self) }
}
