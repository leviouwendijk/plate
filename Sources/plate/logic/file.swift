import Foundation

// convenience wrappers
func readFile(at path: String) -> String? {
    try? String(contentsOfFile: path, encoding: .utf8)
}

func readFile(at path: String) throws -> String {
    try String(contentsOfFile: path, encoding: .utf8)
}
