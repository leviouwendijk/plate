import Foundation

public protocol Base64Encodable {
    func base64() -> String?
}

extension URL: Base64Encodable {
    public func base64() -> String? {
        do {
            let fileData = try Data(contentsOf: self)
            return fileData.base64EncodedString()
        } catch {
            print("Error reading file: \(error)".ansi(.red))
            return nil
        }
    }
}

extension String: Base64Encodable {
    public func base64() -> String? {
        do {
            let url = URL(fileURLWithPath: self)
            let fileData = try Data(contentsOf: url)
            return fileData.base64EncodedString()
        } catch {
            print("Error reading file: \(error)".ansi(.red))
            return nil
        }
    }
}

public protocol Base64Decodable {
    func base64() -> Data?
}

extension String: Base64Decodable {
    public func base64() -> Data? {
        return Data(base64Encoded: self, options: .ignoreUnknownCharacters)
    }
}
