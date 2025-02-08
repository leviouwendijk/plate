import Foundation

public func stripANSI(_ string: String) -> String {
    return string.replacingOccurrences(of: "\u{001B}\\[[0-9;]*[a-zA-Z]", with: "", options: .regularExpression)
}

public func createBox(for content: String) -> String {
    let lines = content.split(separator: "\n")
    
    let strippedLines = lines.map { stripANSI(String($0)) }
    let maxLength = strippedLines.map { $0.count }.max() ?? 0
    
    let horizontalBorder = "+" + String(repeating: "-", count: maxLength + 2) + "+"
    var boxedContent = horizontalBorder + "\n"
    
    for (index, line) in lines.enumerated() {
        let strippedLine = strippedLines[index]
        let paddingCount = maxLength - strippedLine.count
        let paddedLine = line + String(repeating: " ", count: paddingCount)
        boxedContent += "| \(paddedLine) |\n"
    }
    
    boxedContent += horizontalBorder
    return boxedContent
}
