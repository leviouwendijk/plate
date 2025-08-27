import Foundation

public protocol JSONWritable: Codable {}

public extension JSONWritable {
    func json(to url: URL) throws {
        try self.data()
        .write(to: url, options: .atomic)
    }

    func data() throws -> Data {
        let enc = JSONEncoder()
        enc.outputFormatting = [
            .prettyPrinted, 
            .sortedKeys
        ]
        return try enc.encode(self)
    }
}

public protocol JSONReadable: Codable {}

public extension JSONReadable {
    static func decode(_ data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }

    static func read(from data: Data) throws -> Self {
        try decode(data)
    }

    static func read(from url: URL) throws -> Self {
        let data = try Data(contentsOf: url)
        return try read(from: data)
    }

    init(contentsOf url: URL) throws {
        self = try Self.read(from: url)
    }
}
