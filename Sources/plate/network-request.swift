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
                completion(false, data, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let unknownError = NSError(
                    domain: "HTTPError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Unknown response"]
                )
                completion(false, data, unknownError)
                return
            }

            if (200..<300).contains(httpResponse.statusCode) {
                completion(true, data, nil)
            } else {
                let errorMessage: String
                if let data = data, let message = String(data: data, encoding: .utf8) {
                    errorMessage = message
                } else {
                    errorMessage = "Request failed with status code \(httpResponse.statusCode)"
                }
                let statusError = NSError(
                    domain: "HTTPError",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: errorMessage]
                )
                completion(false, data, statusError)
            }
        }.resume()
    }
}

// experimental stream variant of networkrequest
// public final class NetworkRequestStream: NSObject, URLSessionDataDelegate, @unchecked Sendable {
//     private var task: URLSessionDataTask?
//     private var receivedData = Data()
    
//     private let onChunk: (String) -> Void
//     private let onComplete: (Error?) -> Void
    
//     public init(
//         url: URL,
//         method: HTTPMethod = .post,
//         auth: Authorization = .none,
//         headers: [String: String] = [:],
//         body: Data? = nil,
//         onChunk: @escaping (String) -> Void,
//         onComplete: @escaping (Error?) -> Void
//     ) {
//         self.onChunk = onChunk
//         self.onComplete = onComplete
//         super.init()
        
//         var request = URLRequest(url: url)
//         request.httpMethod = method.rawValue
//         request.httpBody = body
        
//         let allHeaders = headers.merging(authorizationHeader(auth)) { _, new in new }
//         for (key, value) in allHeaders {
//             request.addValue(value, forHTTPHeaderField: key)
//         }
        
//         let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
//         self.task = session.dataTask(with: request)
//     }
    
//     public func start() {
//         task?.resume()
//     }
    
//     public func cancel() {
//         task?.cancel()
//     }

//     public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//         receivedData.append(data)

//         while let range = receivedData.range(of: Data([0x0a])) { // newline = \n = 0x0a
//             let lineData = receivedData.subdata(in: 0..<range.lowerBound)
//             receivedData.removeSubrange(0...range.lowerBound)

//             if let line = String(data: lineData, encoding: .utf8), !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                 onChunk(line)
//             }
//         }
//     }
    
//     public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//         onComplete(error)
//     }
    
//     private func authorizationHeader(_ auth: Authorization) -> [String: String] {
//         switch auth {
//         case .none:
//             return [:]
//         case .login(let username, let password):
//             let credentials = "\(username):\(password)"
//             let encoded = Data(credentials.utf8).base64EncodedString()
//             return ["Authorization": "Basic \(encoded)"]
//         case .bearer(let token):
//             return ["Authorization": "Bearer \(token)"]
//         case .custom(let header, let value):
//             return [header: value]
//         case .apikey(let header, let value):
//             return [header: value]
//         }
//     }
// }

public final class NetworkRequestStream: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private var task: URLSessionDataTask?
    private var receivedData = Data()
    
    private let onChunk: (String) -> Void
    private let onComplete: (Error?) -> Void
    
    private let onResponse: ((HTTPURLResponse) -> Void)?
    
    public init(
        url: URL,
        method: HTTPMethod = .post,
        auth: Authorization = .none,
        headers: [String: String] = [:],
        body: Data? = nil,
        onResponse: ((HTTPURLResponse) -> Void)? = nil,
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping (Error?) -> Void
    ) {
        self.onChunk = onChunk
        self.onComplete = onComplete
        self.onResponse = onResponse
        super.init()
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        
        let allHeaders = headers.merging(Self.authorizationHeader(auth)) { _, new in new }
        for (key, value) in allHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.timeoutInterval = 300
        
        // Use a background delegate queue (avoid OperationQueue.main)
        let delegateQueue = OperationQueue()
        delegateQueue.qualityOfService = .userInitiated
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
        self.task = session.dataTask(with: request)
    }
    
    public func start() {
        task?.resume()
    }
    
    public func cancel() {
        task?.cancel()
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
        while let range = receivedData.range(of: Data([0x0a])) { // Look for newline character (\n)
            let lineData = receivedData.subdata(in: 0..<range.lowerBound)
            receivedData.removeSubrange(0...range.lowerBound)
            if let line = String(data: lineData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !line.isEmpty {
                onChunk(line)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let httpResponse = response as? HTTPURLResponse {
            onResponse?(httpResponse)
        }
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        onComplete(error)
    }
    
    private static func authorizationHeader(_ auth: Authorization) -> [String: String] {
        switch auth {
        case .none:
            return [:]
        case .login(let username, let password):
            let credentials = "\(username):\(password)"
            let encoded = Data(credentials.utf8).base64EncodedString()
            return ["Authorization": "Basic \(encoded)"]
        case .bearer(let token):
            return ["Authorization": "Bearer \(token)"]
        case .custom(let header, let value):
            return [header: value]
        case .apikey(let header, let value):
            return [header: value]
        }
    }
}

