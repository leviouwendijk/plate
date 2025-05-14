import Foundation

public func loadDataFromFile(_ filePath: String) -> Data? {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        print("Error: Could not load Data from file at \(filePath)")
        return nil
    }
    return data
}

public func decodeJSON<T: Decodable>(_ data: Data, as type: T.Type) -> T? {
    let decoder = JSONDecoder()
    do {
        let parsedData = try decoder.decode(T.self, from: data)
        return parsedData
    } catch {
        print("Error: Failed to decode JSON - \(error)")
        return nil
    }
}
