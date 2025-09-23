import Foundation

// experimental stream variant of networkrequest

public actor ChunkBuffer {
    private var chunks: [String] = []
    
    public init() { }
    
    public func append(_ chunk: String) {
        chunks.append(chunk)
    }
    
    public func getAndClear() -> [String] {
        let result = chunks
        chunks.removeAll()
        return result
    }
}

public actor DataBufferActor {
    private var buffer = Data()
    
    public init() { }
    
    public func append(_ data: Data) {
        buffer.append(data)
        print("DataBufferActor: appended \(data.count) bytes, total now \(buffer.count) bytes")
    }
    
    public func extractLines() -> [String] {
        var lines: [String] = []
        let newlineData = Data([0x0A])
        
        while let newlineRange = buffer.range(of: newlineData) {
            let lineData = buffer.subdata(in: 0..<newlineRange.lowerBound)
            buffer.removeSubrange(0...newlineRange.lowerBound)
            
            if let line = String(data: lineData, encoding: .utf8) {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    lines.append(trimmed)
                }
            }
        }
        return lines
    }
    
    public func flush() -> String? {
        if !buffer.isEmpty,
           let line = String(data: buffer, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !line.isEmpty {
           print("DataBufferActor: flushing final line: \(line)")
           buffer.removeAll()
           return line
        }
        return nil
    }
}

@available(macOS 10.15, *)
public final class NetworkRequestStream: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private var task: URLSessionDataTask?
    private let dataBuffer = DataBufferActor()
    
    private let onChunk: (String) -> Void
    private let onComplete: (Error?) -> Void
    
    public init(
        url: URL,
        method: HTTPMethod = .post,
        auth: Authorization = .none,
        headers: [String: String] = [:],
        body: Data? = nil,
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping (Error?) -> Void
    ) {
        self.onChunk = onChunk
        self.onComplete = onComplete
        super.init()
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        let allHeaders = headers.merging(Self.authorizationHeader(auth)) { _, new in new }
        for (key, value) in allHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.timeoutInterval = 300
        
        let delegateQueue = OperationQueue()
        delegateQueue.qualityOfService = .userInitiated
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
        // let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        self.task = session.dataTask(with: request)

        print("NetworkRequestStream: Initialized with URL \(url.absoluteString)")
    }
    
    public func start() {
        print("NetworkRequestStream: Starting task")
        task?.resume()
    }
    
    public func cancel() {
        task?.cancel()
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("NetworkRequestStream: didReceive \(data.count) bytes")
        
        // Log the raw response data
        if let rawText = String(data: data, encoding: .utf8) {
            print("NetworkRequestStream: Raw response chunk: \(rawText)")
        } else {
            print("NetworkRequestStream: Received undecodable data")
        }
        
        // Now update the buffer and process the lines
        Task {
            await dataBuffer.append(data)
            let lines = await dataBuffer.extractLines()
            if lines.isEmpty {
                print("NetworkRequestStream: No complete line extracted yet")
            }
            for line in lines {
                print("NetworkRequestStream: Extracted line: \(line)")
                let hexLine = line.data(using: .utf8)?.map { String(format: "%02x", $0) }.joined(separator: " ") ?? "n/a"
                print("NetworkRequestStream: Extracted line (hex): \(hexLine)")

                Task { @MainActor in
                    print("NetworkRequestStream: Calling onChunk with line: \(line)")
                    self.onChunk(line)
                }
            }
        }
    }
    
    public func urlSession(
        _ session: URLSession, dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition
    ) -> Void) {
        if let httpResponse = response as? HTTPURLResponse {
            print("NetworkRequestStream: Response Status: \(httpResponse.statusCode)")
            print("NetworkRequestStream: Response Headers: \(httpResponse.allHeaderFields)")
        }
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Task {
            if let finalLine = await dataBuffer.flush() {
                Task { @MainActor in
                    print("NetworkRequestStream: Flushing final line: \(finalLine)")
                    self.onChunk(finalLine)
                }
            }
            Task { @MainActor in
                print("NetworkRequestStream: Calling onComplete with error: \(String(describing: error))")
                self.onComplete(error)
            }
        }
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

public final class SimpleStreamingDelegate: NSObject, URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let chunk = String(data: data, encoding: .utf8) {
            print("Received chunk: \(chunk)")
        } else {
            print("Received \(data.count) bytes (undecodable)")
        }
    }
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let httpResponse = response as? HTTPURLResponse {
            print("Response Status: \(httpResponse.statusCode)")
            print("Response Headers: \(httpResponse.allHeaderFields)")
        }
        completionHandler(.allow)
    }
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Streaming ended with error: \(error)")
        } else {
            print("Streaming complete.")
        }
    }
}

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
