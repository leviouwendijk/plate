import Foundation

// extension String {
//     public var strippingNorgMetadata: String {
//         return self
//         .replacingOccurrences(
//             of: #"(?s)@document\.meta.*?@end"#,
//             with: "",
//             options: .regularExpression
//         )
//     }

//     public var splitByNewlines: [String] {
//         return self
//         .components(separatedBy: .newlines)
//     }

//     public func collapsingDoubleSpaces() -> String {
//         return self.replacingOccurrences(
//             of: " {2,}",
//             with: " ",
//             options: .regularExpression
//         )
//     }

//     // public func emDashedFromHyphens() -> String {
//     //     return self.replacingOccurrences(of: "--", with: "—")
//     // }
// }

extension String {
    public func removepattern(_ pattern: String) -> String {
        return self
        .replacingOccurrences(
            of: pattern,
            with: "",
            options: .regularExpression
        )
    }

    public func spacecollapse(_ count: Int = 2) -> String {
        return self.replacingOccurrences(
            of: " {\(count),}",
            with: " ",
            options: .regularExpression
        )
    }

    public var emdashed: String {
        return self.replacingOccurrences(of: "--", with: "—")
    }

    public var newlinesplit: [String] {
        return self
        .components(separatedBy: .newlines)
    }
}
