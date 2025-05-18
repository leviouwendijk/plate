import Foundation

// ----------
// ENCODING
// ----------

public protocol Base64Encodable {
    func base64() throws -> String
}

// old v:
// extension URL: Base64Encodable {
//     // public func base64() throws -> String {
//     //     do {
//     //         let fileData = try Data(contentsOf: self)
//     //         return fileData.base64EncodedString()
//     //     } catch {
//     //         print("Error reading file: \(error)".ansi(.red))
//     //         return nil
//     //     }
//     // }
// }

extension String: Base64Encodable {
    public func base64() throws -> String {
        let url = URL(fileURLWithPath: self)
        let fileData = try Data(contentsOf: url)
        return fileData.base64EncodedString()
    }
}

// new with throws

extension URL: Base64Encodable {
    public func base64() throws -> String {
        try Data(contentsOf: self).base64EncodedString()
    }
}

// ----------
// DECODING
// ----------
// public protocol Base64Decodable {
//     func base64() -> Data?
// }

// extension String: Base64Decodable {
//     public func base64() -> Data? {
//         return Data(base64Encoded: self, options: .ignoreUnknownCharacters)
//     }
// }

public enum Base64DecodingError: Error {
    case invalidBase64(String)
}

public protocol Base64Decodable {
    func base64Decoded() throws -> Data
}

extension String: Base64Decodable {
    public func base64Decoded() throws -> Data {
        let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters)
        guard let decoded = data else {
            throw Base64DecodingError.invalidBase64(self)
        }
        return decoded
    }
}
