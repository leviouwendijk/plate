import Foundation
import AppKit

public enum CopyClipboardError: Error {
    case fileNotFound(String)
    case copyFailure(String)
}

// as function calls, backwards compatibility
public func copyToClipboard(_ text: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
}

// was the same as copyToClipboard, may need refactoring in places where this name called NSAttributed strings
public func copyNSToClipboard(_ attributedString: NSAttributedString) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.writeObjects([attributedString])
}

// now also as protocols
public protocol StringCopyable {
    func sCopy()
}

extension String: StringCopyable {
    public func sCopy() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(self, forType: .string)

    }

    public func scp() {
        self.sCopy()
    }
}

public protocol NSAttributedStringCopyable {
    func nsCopy()
}

extension NSAttributedString: NSAttributedStringCopyable {
    public func nsCopy() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([self])

    }
}

// private extension NSPasteboard.PasteboardType {
//     static let utf8PlainText = NSPasteboard.PasteboardType("public.utf8-plain-text")
// }

// public func copyToClipboard(_ text: String) {
//     let pb = NSPasteboard.general
//     pb.clearContents()
//     // Be explicit + multi-type (order: declare → set)
//     pb.declareTypes([.string, .utf8PlainText], owner: nil)
//     _ = pb.setString(text, forType: .string)
//     if let data = text.data(using: .utf8) {
//         _ = pb.setData(data, forType: .utf8PlainText)
//     }
// }

// public func copyNSToClipboard(_ attributedString: NSAttributedString) {
//     let pb = NSPasteboard.general
//     pb.clearContents()

//     // Write the attributed payload (RTF) *and* a plain-text fallback.
//     var declared: [NSPasteboard.PasteboardType] = []
//     if let rtf = try? attributedString.data(from: NSRange(location: 0, length: attributedString.length),
//                                             documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
//         declared.append(.rtf)
//         pb.declareTypes([.rtf], owner: nil)
//         _ = pb.setData(rtf, forType: .rtf)
//     }

//     // Always also expose plain text for cli/nvim readers
//     let text = attributedString.string
//     if !declared.isEmpty {
//         // We already declared once; append additional types
//         _ = pb.setString(text, forType: .string)
//         if let data = text.data(using: .utf8) {
//             _ = pb.setData(data, forType: .utf8PlainText)
//         }
//     } else {
//         // Fallback path: declare plain text types
//         pb.declareTypes([.string, .utf8PlainText], owner: nil)
//         _ = pb.setString(text, forType: .string)
//         if let data = text.data(using: .utf8) {
//             _ = pb.setData(data, forType: .utf8PlainText)
//         }
//     }
// }

// public protocol StringCopyable { func sCopy() }

// extension String: StringCopyable {
//     public func sCopy() { copyToClipboard(self) }
//     public func scp() { sCopy() }
// }

// public protocol NSAttributedStringCopyable { func nsCopy() }
// extension NSAttributedString: NSAttributedStringCopyable {
//     public func nsCopy() { copyNSToClipboard(self) }
// }

public func copyFileObjectToClipboard(path file: String) throws {
    guard FileManager.default.fileExists(atPath: file) else {
        throw CopyClipboardError.fileNotFound("No file found at path: \(file)")
    }
    let fileURL = URL(fileURLWithPath: file)
    
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    
    let success = pasteboard.writeObjects([fileURL as NSURL])
    
    if success {
        print("File copied to clipboard as a file reference.")
    } else {
        throw CopyClipboardError.copyFailure("Failed to copy PDF file to clipboard.")
    }
}
