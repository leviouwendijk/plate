import Foundation

public func preflightSafeWrite(
    _ targets: [URL],
    options: SafeWriteOptions
) throws {
    let fm = FileManager.default

    func isNonBlank(_ url: URL) -> Bool {
        guard fm.fileExists(atPath: url.path) else { return false }
        guard let data = try? Data(contentsOf: url, options: .uncached) else { return false }
        if data.isEmpty { return false }
        if options.whitespaceOnlyIsBlank,
           let s = String(data: data, encoding: .utf8),
           s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        return true
    }

    // Collisions = existing non-blank files
    let collisions = targets.filter(isNonBlank)

    if !collisions.isEmpty && options.overrideExisting == false {
        throw SafePreflightError.refusingToOverwrite(collisions)
    }

    // If overriding, create backups for the collisions
    guard options.overrideExisting && options.makeBackupOnOverride else { return }

    let df = DateFormatter()
    df.dateFormat = "yyyyMMdd_HHmmss"
    df.locale = Locale(identifier: "en_US_POSIX")
    let ts = df.string(from: Date())

    for url in collisions {
        let backup = url.deletingLastPathComponent()
            .appendingPathComponent(url.lastPathComponent + options.backupSuffix, isDirectory: false)

        if fm.fileExists(atPath: backup.path) {
            let tsBackup = url.deletingLastPathComponent()
                .appendingPathComponent(url.lastPathComponent + ".\(ts)" + options.backupSuffix, isDirectory: false)
            try fm.copyItem(at: url, to: tsBackup)
        } else {
            try fm.copyItem(at: url, to: backup)
        }
    }
}
