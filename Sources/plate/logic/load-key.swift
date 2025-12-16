import Foundation

public func loadKey(at path: String) throws -> String {
    let url = URL(filePath: path)
    let str = try String(contentsOf: url, encoding: .utf8)
    return str
}
