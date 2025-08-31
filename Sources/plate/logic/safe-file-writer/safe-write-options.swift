import Foundation

public struct SafeWriteOptions: Sendable {
    /// If true and the file exists & is not blank, allow overwrite.
    public var overrideExisting: Bool
    /// If overriding, also write a backup first.
    public var makeBackupOnOverride: Bool
    /// Treat whitespace-only files as "blank".
    public var whitespaceOnlyIsBlank: Bool
    /// When making a backup, append this suffix to the filename.
    /// Example: "notes.txt" -> "notes.txt_previous_version.bak"
    public var backupSuffix: String
    /// If a backup with the same name already exists, add a timestamp to avoid clobbering.
    public var addTimestampIfBackupExists: Bool
    /// Write atomically (via `.atomic`).
    public var atomic: Bool

    public init(
        overrideExisting: Bool = false,
        makeBackupOnOverride: Bool = true,
        whitespaceOnlyIsBlank: Bool = false,
        backupSuffix: String = "_previous_version.bak",
        addTimestampIfBackupExists: Bool = true,
        atomic: Bool = true
    ) {
        self.overrideExisting = overrideExisting
        self.makeBackupOnOverride = makeBackupOnOverride
        self.whitespaceOnlyIsBlank = whitespaceOnlyIsBlank
        self.backupSuffix = backupSuffix
        self.addTimestampIfBackupExists = addTimestampIfBackupExists
        self.atomic = atomic
    }
}
