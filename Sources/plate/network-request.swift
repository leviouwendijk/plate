import Foundation

public func requestHTTP(
    url: URL,
    httpMethod: String,
    headers: [String: String]? = nil,
    body: Data?,
    logDebug: Bool = false,
    completion: @escaping @Sendable (Bool, Data?, Error?) -> Void
) {
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod
    headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
    request.httpBody = body
    request.timeoutInterval = 60

    URLSession.shared.dataTask(with: request) { data, response, error in
        if logDebug, let httpResponse = response as? HTTPURLResponse {
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
