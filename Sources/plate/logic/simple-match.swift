public func simpleMatch(
    in string: String,
    identifiers: [String]
) -> Bool {
    for ident in identifiers {
        if string == ident {
            return true 
        } else {
            continue
        }
    }
    return false
}
