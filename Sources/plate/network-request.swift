import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
}

public struct NetworkRequest: Sendable {
    public let url: URL
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?
    public let log: Bool

    public init(
        url: URL,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil,
        log: Bool = false
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.log = log
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
