import Foundation

public enum APIKey: String, Sendable {
    case lowercase = "x-api-key"
    case uppercase = "X-API-Key"
}

public enum Authorization: Sendable {
    case none
    case login(username: String, password: String)
    case bearer(token: String)
    case custom(header: String, value: String)
    case apikey(header: String = APIKey.lowercase.rawValue, value: String)
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"  
    case patch = "PATCH"    
    case head = "HEAD"      
    case options = "OPTIONS" 
    case trace = "TRACE"    
    case connect = "CONNECT" 
}

public struct NetworkRequest: Sendable {
    public let url: URL
    public let method: HTTPMethod
    public let auth: Authorization
    public var headers: [String: String]
    public let body: Data?
    public let log: Bool

    public init(
        url: URL,
        method: HTTPMethod,
        auth: Authorization,
        headers: [String: String] = [:],
        body: Data? = nil,
        log: Bool = false
    ) {
        self.url = url
        self.method = method
        self.auth = auth
        self.body = body
        self.log = log
        self.headers = [:]

        var completeHeaders = headers
        completeHeaders.merge(authorizationHeader(auth)) { (_, new) in new }
        self.headers = completeHeaders
    }

    private func authorizationHeader(_ auth: Authorization) -> [String: String] {
        switch auth {
        case .none:
            return [:]
        case .login(let username, let password):
            let credentials = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() ?? ""
            return ["Authorization": "Basic \(credentials)"]
        case .bearer(let token):
            return ["Authorization": "Bearer \(token)"]
        case .custom(let header, let value):
            return [header: value]
        case .apikey(let header, let value):
            return [header: value]
        }
    }
    
    public func execute(completion: @escaping @Sendable (Bool, Data?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        request.httpBody = body
        request.timeoutInterval = 60

        URLSession.shared.dataTask(with: request) { data, response, error in
            if log, let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }

            if let error = error {
                completion(false, nil, error)
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                let statusError = NSError(
                    domain: "HTTPError",
                    code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                    userInfo: [NSLocalizedDescriptionKey: "Request failed"]
                )
                completion(false, nil, statusError)
                return
            }
            
            completion(true, data, nil)
        }.resume()
    }
}
