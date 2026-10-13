import Foundation
import Parsers
import Version

extension PklParser {
    public func parseLegacyBuildObject() throws -> BuildObjectConfiguration.LegacyObject {
        do {
            let document = try Pkl.parse(String(input[idx...]))
            let value = try BuildObjectPklDecoder.legacy(document)
            idx = input.endIndex
            return value
        } catch let syntax as Pkl.SyntaxFailure {
            throw PklParserError.syntaxError(syntax.description)
        }
    }
}
