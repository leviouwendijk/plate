import Foundation
import CryptoKit

public func hash(_ raw: String) -> String {
    let data = Data(raw.utf8)
    let digest = SHA256.hash(data: data)
    return digest.compactMap { String(format: "%02x", $0) }.joined()
}
