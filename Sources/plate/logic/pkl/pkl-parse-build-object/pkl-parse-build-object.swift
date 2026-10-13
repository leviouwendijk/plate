import Foundation
import Parsers

extension PklParser {
    public func parseBuildObject() throws -> BuildObjectConfiguration {
        do {
            let document = try Pkl.parse(String(input[idx...]))
            let value = try BuildObjectPklDecoder.modern(document)
            idx = input.endIndex
            return value
        } catch let syntax as Pkl.SyntaxFailure {
            throw PklParserError.syntaxError(syntax.description)
        }
    }
}
