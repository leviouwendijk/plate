import Foundation

// Read the file content
func readFile(at path: String) -> String? {
    try? String(contentsOfFile: path, encoding: .utf8)
}
