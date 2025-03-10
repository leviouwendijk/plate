import Foundation

// experimental phase:

public struct IndexableDictionary<Key: Hashable & Codable, Value: Codable>: Codable {
    public var keys: [Key] = []
    public var values: [Key: Value] = [:]

    public init() {}

    public subscript(index: Int) -> (Key, Value)? {
        guard index >= 0, index < keys.count, let value = values[keys[index]] else { return nil }
        return (keys[index], value)
    }

    public subscript(key: Key) -> Value? {
        get { return values[key] }
        set {
            if let newValue = newValue {
                if values[key] == nil { keys.append(key) }
                values[key] = newValue
            } else {
                values.removeValue(forKey: key)
                keys.removeAll { $0 == key }
            }
        }
    }

    public func jsonRepresentation() -> String? {
        var orderedDict: [Key: Value] = [:]
        for key in keys { orderedDict[key] = values[key] }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(orderedDict),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}
