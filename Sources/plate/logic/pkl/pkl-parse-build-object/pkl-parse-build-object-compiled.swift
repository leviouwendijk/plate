import Foundation
import Parsers
import Version

extension PklParser {
    public func parseCompiledBuildObject() throws -> CompiledLocalBuildObject {
        do {
            let document = try Pkl.parse(String(input[idx...]))
            let value = try BuildObjectPklDecoder.compiled(document)
            idx = input.endIndex
            return value
        } catch let syntax as Pkl.SyntaxFailure {
            throw PklParserError.syntaxError(syntax.description)
        }
    }
}
