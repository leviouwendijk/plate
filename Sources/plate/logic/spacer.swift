import Foundation
// Spacer functions

// Basic:
public func printSpacerBasic(_ lines: Int) {
    var reps = lines

    while reps != 0 {
        print("")
        reps -= 1
    }
}

// Defining particular characters and printing a set length 

// Setting up an enumeration
public enum LineStyle: Sendable {
    case blank
    case hash
    case line
    case dot
}

// Using enumeration as argument, involving a predefined length
public func printSpacer(_ lines: Int = 1, _ style: LineStyle? = .blank,_ length: Int = 80) {
    var reps = lines 

    while reps != 0 {
        switch style {
            case .blank, .none:
            print(String(repeating: "", count: length))
            case .hash:
            print(String(repeating: "#", count: length))
            case .line:
            print(String(repeating: "-", count: length))
            case .dot:
            print(String(repeating: ".", count: length))
        }
        reps -= 1
    }
}

public struct Divider {
    public let separator: LineStyle 
    public let separatorLines: Int 
    public let length: Int
    public let whitelines: Int 

    public init(separator: LineStyle, separatorLines: Int, length: Int, whitelines: Int) {
        self.separator = separator
        self.separatorLines = separatorLines
        self.length = length
        self.whitelines = whitelines
    }
}

public func makeDividerFromConfig(_ dividerConfig: Divider) -> () -> Void {
    return {
        let div = dividerConfig

        printSpacer(div.whitelines, .blank)
        printSpacer(div.separatorLines, div.separator, div.length)
        printSpacer(div.whitelines, .blank)
    }
}

public func defaultDivider() { 
    let dividerConfig: Divider = Divider(
        separator: .line, 
        separatorLines: 1,
        length: 60,
        whitelines: 2
    )
    makeDividerFromConfig(dividerConfig)()
}
