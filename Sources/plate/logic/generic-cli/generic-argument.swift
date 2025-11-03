import Foundation

public struct ProcessableGenericArgument {
    public let id: String
    public let aliases: [GenericArgumentAlias]
    public let kind: GenericArgumentKind
    // let action: () -> Void

    public func match(
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
