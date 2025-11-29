extension Optional {
    public var isNil: Bool { self == nil }
    public var isNotNil: Bool { self != nil }

    public var notNil: Bool { self.isNotNil }
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

    public var notAllNil: Bool {
        return !self.allNil
    }
}

extension Array where Element == Any? {
    public var allNil: Bool {
        return plate.all_nil(self)
    }

    public var notAllNil: Bool {
        return !self.allNil
    }
}

extension Array where Element == String {
    public var allNil: Bool {
        return plate.all_nil(self)
    }

    public var notAllNil: Bool {
        return !self.allNil
    }
}

extension Array where Element == String? {
    public var allNil: Bool {
        return plate.all_nil(self)
    }

    public var notAllNil: Bool {
        return !self.allNil
    }
}
