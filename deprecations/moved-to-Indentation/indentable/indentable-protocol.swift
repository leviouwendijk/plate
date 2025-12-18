import Foundation

// public protocol StringIndentable {
public protocol Indentable {
    func indent(_ size: Int, times: Int, overrides: [IndentationOverride]) -> String
    func indent(options: IndentationOptions) -> String
}
