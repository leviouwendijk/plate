import Foundation

public struct IndexableDictionary<Key: Hashable & Codable, Value: Codable>: Codable {
    private var keys: [Key] = []
    private var values: [Key: Value] = [:]

    public init() {}

    /// Indexed access (e.g., `dict[1]` gives 2nd item)
    public subscript(index: Int) -> (Key, Value)? {
        guard index >= 0, index < keys.count, let value = values[keys[index]] else { return nil }
        return (keys[index], value)
    }

    /// Dictionary-like access
    public subscript(key: Key) -> Value? {
        get { return values[key] }
        set {
            if let newValue = newValue {
                if values[key] == nil { keys.append(key) } // Keep insertion order
                values[key] = newValue
            } else {
                values.removeValue(forKey: key)
                keys.removeAll { $0 == key }
            }
        }
    }

    /// JSON Representation: Ordered JSON object, not an array
    public func jsonRepresentation() -> String? {
        var orderedDict: [Key: Value] = [:]
        for key in keys { orderedDict[key] = values[key] }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Keep order intact
        if let jsonData = try? encoder.encode(orderedDict),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}
