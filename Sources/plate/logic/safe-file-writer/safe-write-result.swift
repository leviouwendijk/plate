import Foundation

public struct SafeWriteResult: Sendable {
    public let wrote: Bool
    public let backupURL: URL?
    public let overwrittenExisting: Bool
}
