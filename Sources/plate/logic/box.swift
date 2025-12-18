import Foundation
import Indentation

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

public func makeQuickSummary(
    _ values: [(name: String, amount: Double)],
    _ title: String = "Quick Summary:"
) -> String {
    var summaryString = ""
    summaryString.append(title)
    summaryString.append("\n\n")

    var stringToBox = ""
    for value in values {
        let string = leftAlignText(value.name.ansi(.bold), width: 25) + rightAlignText("\(value.amount)".ansi(.bold), width: 25)
        stringToBox.append(string)
        stringToBox.append("\n")
    }
    
    let box = createBox(for: stringToBox)
    summaryString.append(box)

    return summaryString.indent()
}
