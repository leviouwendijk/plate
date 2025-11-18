public enum StandardLoggerWriteMode: Sendable {
    /// Default: do not touch existing contents; create file if missing.
    case append

    /// Truncate the file at startup, but use SafeFile to make backups according to options.
    case reset(options: SafeWriteOptions = SafeWriteOptions())
}
