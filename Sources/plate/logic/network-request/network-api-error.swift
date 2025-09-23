import Foundation

public struct APIError: Codable, Error {
    public let success: Bool
    public let message: String
    public let error: String?
    public let missing: [String]?

    public init(
        success: Bool,
        message: String,
        error: String? = nil,
        missing: [String]? = nil
    ) {
        self.success = success
        self.message = message
        self.error   = error
        self.missing = missing
    }
}

extension APIError: LocalizedError, CustomStringConvertible {
    public var errorDescription: String? {
        var parts: [String] = [message]
        if let e = error, !e.isEmpty { parts.append("(\(e))") }
        if let missing, !missing.isEmpty {
            parts.append("missing: \(missing.joined(separator: ", "))")
        }
        return parts.joined(separator: " ")
    }

    public var failureReason: String? {
        error?.isEmpty == false ? error : nil
    }

    public var recoverySuggestion: String? {
        guard let missing, !missing.isEmpty else { return nil }
        return "Provide required fields: \(missing.joined(separator: ", "))."
    }

    public var description: String {
        errorDescription ?? message
    }

    public static func decode(from data: Data) -> APIError? {
        try? JSONDecoder().decode(APIError.self, from: data)
    }

    public static func fromTransport(_ error: Error?) -> APIError {
        let ns = (error as NSError?) ?? NSError(
            domain: "HTTPError", 
            code: -1,
            userInfo: [
            NSLocalizedDescriptionKey: "Unknown error"]
        )

        return APIError(
            success: false,
            message: ns.localizedDescription,
            error: "\(ns.domain) (\(ns.code))",
            missing: nil
        )
    }
}
