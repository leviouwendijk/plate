public func all_nil(_ vals: [Any]) -> Bool {
    let reduced = vals.compactMap { $0 }
    return reduced.isEmpty
}
