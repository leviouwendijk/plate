import Foundation

public enum DocumentExtensionError: Error, Sendable {
    case unsupportedExtension(filename: String)
}

public enum DocumentExtensionType: String, RawRepresentable, CaseIterable, Sendable, Codable {
    case txt
    case md
    case norg
    case html
    case pdf
    case css

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

    case png
    case jpg
    case jpeg
    case webp

    case xml
    case json
    case yaml
    case yml

    case base64

    public var dotPrefixed: String {
        return ".\(self.rawValue)"
    }

    public init?(fileExtension: String) {
        let cleaned = fileExtension.hasPrefix(".") ? String(fileExtension.dropFirst()).lowercased() : fileExtension.lowercased()
        self.init(rawValue: cleaned)
    }

    public init(filename: String) throws {
        let lowercased = filename.lowercased()

        let sorted = DocumentExtensionType.allCases
            .sorted { $0.dotPrefixed.count > $1.dotPrefixed.count }

        for ext in sorted {
            if lowercased.hasSuffix(ext.dotPrefixed) {
                self = ext
                return
            }
        }
        throw DocumentExtensionError.unsupportedExtension(filename: filename)
    }
}
