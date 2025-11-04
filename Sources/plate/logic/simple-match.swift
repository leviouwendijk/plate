public func simpleMatch(
    in string: String,
    identifiers: [String],
    lowercasing: Bool = true
) -> Bool {
    let str = string.lowercased()
    for ident in identifiers {
        if str == ident {
            return true 
        } else {
            continue
        }
    }
    return false
}
