extension Optional {
    public func ifNotNil(_ closure: (Wrapped) -> Void) {
        if let value = self {
            closure(value)
        }
    }
}
