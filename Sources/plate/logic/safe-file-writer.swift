import Foundation

public enum SafeFileError: Error, LocalizedError {
    case parentDirectoryMissing(URL)
    case fileExistsAndNotBlank(URL)
    case backupNotFound(URL)
    case nothingToRestore(URL)
    case io(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .parentDirectoryMissing(let url):
            return "Parent directory does not exist for: \(url.path)"
        case .fileExistsAndNotBlank(let url):
            return "Refusing to overwrite non-blank file without override: \(url.path)"
        case .backupNotFound(let url):
            return "Backup not found at: \(url.path)"
        case .nothingToRestore(let url):
            return "No current file to replace at: \(url.path)"
        case .io(let underlying):
            return "I/O error: \(underlying.localizedDescription)"
        }
    }
}

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

public struct SafeWriteResult: Sendable {
    public let wrote: Bool
    public let backupURL: URL?
    public let overwrittenExisting: Bool
}

public struct SafeFile {
    public let url: URL

    public init(
        _ url: URL
    ) { 
        self.url = url
    }

    public func defaultBackupURL(suffix: String) -> URL {
        let base = url.lastPathComponent + suffix
        return url.deletingLastPathComponent().appendingPathComponent(base, isDirectory: false)
    }

    @discardableResult
    public func write(_ data: Data, options: SafeWriteOptions = .init()) throws -> SafeWriteResult {
        do {
            try ensureParentExists()

            let fm = FileManager.default
            var backupURL: URL? = nil
            var overwritten = false

            if fm.fileExists(atPath: url.path) {
                let isBlank = try fileIsBlank(whitespaceCounts: options.whitespaceOnlyIsBlank)
                if !isBlank && !options.overrideExisting {
                    throw SafeFileError.fileExistsAndNotBlank(url)
                }

                if !isBlank && options.overrideExisting {
                    overwritten = true
                    if options.makeBackupOnOverride {
                        backupURL = try makeBackup(
                            suffix: options.backupSuffix,
                            addTimestampIfExists: options.addTimestampIfBackupExists
                        )
                    }
                }
            }

            let writeOptions: Data.WritingOptions = options.atomic ? [.atomic] : []
            try data.write(to: url, options: writeOptions)

            return .init(wrote: true, backupURL: backupURL, overwrittenExisting: overwritten)
        } catch let e as SafeFileError {
            throw e
        } catch {
            throw SafeFileError.io(underlying: error)
        }
    }

    @discardableResult
    public func write(_ string: String, encoding: String.Encoding = .utf8, options: SafeWriteOptions = .init()) throws -> SafeWriteResult {
        guard let data = string.data(using: encoding) else {
            throw SafeFileError.io(underlying: NSError(domain: "SafeFile", code: -1, userInfo: [NSLocalizedDescriptionKey: "String encoding failed"]))
        }
        return try write(data, options: options)
    }

    /// Returns a simple unified-like diff (lines starting with " - " / " + ").
    /// If `backupURL` is nil, uses the default backup path.
    public func diffAgainstBackup(backupURL: URL? = nil, encoding: String.Encoding = .utf8, backupSuffix: String = "_previous_version.bak") throws -> String {
        let fm = FileManager.default
        let bu = backupURL ?? defaultBackupURL(suffix: backupSuffix)
        guard fm.fileExists(atPath: bu.path) else { throw SafeFileError.backupNotFound(bu) }
        guard fm.fileExists(atPath: url.path) else { throw SafeFileError.nothingToRestore(url) }

        let oldStr = try String(contentsOf: bu, encoding: encoding)
        let newStr = try String(contentsOf: url, encoding: encoding)
        return makeSimpleLineDiff(old: oldStr, new: newStr, oldName: bu.lastPathComponent, newName: url.lastPathComponent)
    }

    /// Restores the backup over the current file. By default, preserves the current file to a timestamped ".restore_point.bak".
    @discardableResult
    public func restoreFromBackup(backupURL: URL? = nil, backupSuffix: String = "_previous_version.bak", keepCurrentAsRestorePoint: Bool = true) throws -> URL {
        let fm = FileManager.default
        let bu = backupURL ?? defaultBackupURL(suffix: backupSuffix)
        guard fm.fileExists(atPath: bu.path) else { throw SafeFileError.backupNotFound(bu) }

        if fm.fileExists(atPath: url.path), keepCurrentAsRestorePoint {
            let rp = timestampedSibling(for: url, extraSuffix: ".restore_point.bak")
            try fm.copyItem(at: url, to: rp)
        }

        // Replace current with backup (copy then replace for safety)
        let tmp = timestampedSibling(for: url, extraSuffix: ".tmp.restore")
        try? fm.removeItem(at: tmp)
        try fm.copyItem(at: bu, to: tmp)
        try replaceItem(at: url, with: tmp) // atomic-ish replace
        return url
    }

    private func ensureParentExists() throws {
        let parent = url.deletingLastPathComponent()
        let fm = FileManager.default
        var isDir: ObjCBool = false
        if !fm.fileExists(atPath: parent.path, isDirectory: &isDir) || !isDir.boolValue {
            throw SafeFileError.parentDirectoryMissing(url)
        }
    }

    private func fileIsBlank(whitespaceCounts: Bool) throws -> Bool {
        let data = try Data(contentsOf: url, options: .uncached)
        if data.isEmpty { return true }
        guard whitespaceCounts else { return false }
        if let s = String(data: data, encoding: .utf8) {
            return s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return false
    }

    private func makeBackup(suffix: String, addTimestampIfExists: Bool) throws -> URL {
        let fm = FileManager.default
        var bu = defaultBackupURL(suffix: suffix)
        if fm.fileExists(atPath: bu.path), addTimestampIfExists {
            bu = timestampedSibling(for: bu)
        }
        try? fm.removeItem(at: bu) // be permissive if not timestamping
        try fm.copyItem(at: url, to: bu)
        return bu
    }

    private func timestampedSibling(for original: URL, extraSuffix: String = "") -> URL {
        let stamp = SafeFile.timestamp()
        let name = original.lastPathComponent + "." + stamp + extraSuffix
        return original.deletingLastPathComponent().appendingPathComponent(name, isDirectory: false)
    }

    private static func timestamp() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_HHmmss"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.string(from: Date())
    }

    private func replaceItem(at dst: URL, with src: URL) throws {
        let fm = FileManager.default
        do {
            if fm.fileExists(atPath: dst.path) {
                try fm.removeItem(at: dst)
            }
            try fm.moveItem(at: src, to: dst)
        } catch {
            throw SafeFileError.io(underlying: error)
        }
    }
}

private func makeSimpleLineDiff(old: String, new: String, oldName: String, newName: String) -> String {
    let oldLines = old.replacingOccurrences(of: "\r\n", with: "\n").split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    let newLines = new.replacingOccurrences(of: "\r\n", with: "\n").split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

    var i = 0, j = 0
    var out: [String] = []
    out.append("--- \(oldName)")
    out.append("+++ \(newName)")

    while i < oldLines.count || j < newLines.count {
        if i < oldLines.count && j < newLines.count && oldLines[i] == newLines[j] {
            // unchanged line: skip to keep diff concise; uncomment to show:
            // out.append("   \(oldLines[i])")
            i += 1; j += 1
        } else if j + 1 < newLines.count, i < oldLines.count, oldLines[i] == newLines[j + 1] {
            // insertion
            out.append(" + \(newLines[j])")
            j += 1
        } else if i + 1 < oldLines.count, j < newLines.count, oldLines[i + 1] == newLines[j] {
            // deletion
            out.append(" - \(oldLines[i])")
            i += 1
        } else {
            // change (replace one line with another)
            if i < oldLines.count { out.append(" - \(oldLines[i])"); i += 1 }
            if j < newLines.count { out.append(" + \(newLines[j])"); j += 1 }
        }
    }
    return out.joined(separator: "\n")
}

// let file = SafeFile(URL(fileURLWithPath: "/path/to/output.txt"))

// // 1) Safe write (will throw if non-blank file exists)
// try file.write("Hello\n")

// // 2) Override with backup
// var opts = SafeWriteOptions(overrideExisting: true, makeBackupOnOverride: true)
// try file.write("Hello new world\n", options: opts)

// // 3) Show diff against backup
// let diff = try file.diffAgainstBackup()
// print(diff)

// // 4) Restore from backup
// try file.restoreFromBackup()
