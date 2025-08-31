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
