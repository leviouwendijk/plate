import Foundation

extension PklParser {
    public func parseLegacyBuildObject() throws -> BuildObjectConfiguration.LegacyObject {
        var uuid: UUID?
        var name: String?
        var type: ExecutableObjectType?
        var version: ObjectVersion?
        var details: String?
        var author: String?
        var update: String?

        while skipWhitespaceAndNewlines() {
            let key = try parseIdentifier()
            skipWhitespaceAndNewlines()
            if key == "version" {
                version = try parseVersionBlock()
                continue
            } else {
                try expect("=")
                let val = try parseValue()
                switch key {
                case "uuid":
                    guard let s = val as? String, let u = UUID(uuidString: s) else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    uuid = u
                case "name":
                    guard let s = val as? String else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    name = s
                case "type":
                    guard let s = val as? String, let t = ExecutableObjectType(rawValue: s) else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    type = t
                case "details":
                    guard let s = val as? String else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    details = s
                case "author":
                    guard let a = val as? String else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    author = a
                case "update":
                    guard let u = val as? String else {
                        throw PklParserError.invalidValue(field: key, value: "\(val)")
                    }
                    update = u
                default:
                    break
                }
            }
        }

        guard let uu = uuid else     { throw PklParserError.missingField("uuid") }
        guard let nm = name else     { throw PklParserError.missingField("name") }
        guard let tp = type else    { throw PklParserError.missingField("type") }
        guard let ver = version else { throw PklParserError.missingField("version") }
        guard let det = details else { throw PklParserError.missingField("details") }
        guard let au = author else     { throw PklParserError.missingField("author") }
        guard let up = update else     { throw PklParserError.missingField("update") }

        return BuildObjectConfiguration.LegacyObject(
            uuid: uu, 
            name: nm, 
            type: tp,
            version: ver, 
            details: det,
            author: au,
            update: up
        )
    }
}
