import Foundation

public enum DocumentExtensionType: String, CaseIterable {
    case txt
    case md
    case norg
    case html
    case pdf

    case doc
    case docx
    case rtf
    case odt

    case csv
    case xls
    case xlsx

    case ppt
    case pptx

    case epub
    case mobi

    case xml
    case json
    case yaml
    case yml

    public var dotPrefixed: String {
        return ".\(self.rawValue)"
    }
}
