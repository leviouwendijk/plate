import Foundation

func convertDictionaryToSet(_ dictionary: [String: String], output: String) -> Set<String> {
    switch output.lowercased() {
    case "keys", "a", "first":
        return Set(dictionary.keys)
    case "values", "b", "second":
        return Set(dictionary.values)
    default:
        print("Invalid argument. Please specify 'keys' or 'values'.")
        return []
    }
}
