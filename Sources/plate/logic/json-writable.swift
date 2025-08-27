import Foundation

public protocol JSONWritable: Codable {}

public extension JSONWritable {
    func json(to url: URL) throws {
        let enc = JSONEncoder()
        enc.outputFormatting = [
            .prettyPrinted, 
            .sortedKeys
        ]
        try enc.encode(self)
        .write(to: url, options: .atomic)
    }
}
