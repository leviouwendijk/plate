import Foundation

struct ProcessableGenericArgument {
    let id: String
    let aliases: [GenericArgumentAlias]
    let kind: GenericArgumentKind
    // let action: () -> Void

    func match(
        identifiers: [String]
    ) -> Bool {
        for ident in identifiers {
            for alias in aliases {
                if alias.identifier == ident {
                    return true 
                } else {
                    continue
                }
            }
        }
        return false
    }
}
