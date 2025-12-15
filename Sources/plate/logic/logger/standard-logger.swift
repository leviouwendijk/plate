import Foundation

#if os(macOS)
public actor StandardLogger {
    public var minimumLevel: LogLevel
    public var onError: ((Error) -> Void)?
    private var fileHandle: FileHandle?
    
    public init(
        logFileURL: URL,
        minimumLevel: LogLevel = .info,
        writeMode: StandardLoggerWriteMode = .append
    ) throws {
        self.fileHandle = try Self.makeFileHandle(for: logFileURL, writeMode: writeMode)
        self.minimumLevel = minimumLevel
    }
    
    public init(
        name: String,
        minimumLevel: LogLevel = .info,
        writeMode: StandardLoggerWriteMode = .append
    ) throws {
        let url = Home.url()
        .appendingPathComponent("api-logs")
        .appendingPathComponent("\(name).log")

        self.fileHandle = try Self.makeFileHandle(for: url, writeMode: writeMode)
        self.minimumLevel = minimumLevel
    }

    public init(
        name: String?,
        minimumLevel: LogLevel = .info,
        writeMode: StandardLoggerWriteMode = .append
    ) throws {
        guard let name else {
            throw StandardLoggerError.appNameEmpty
        }
        try self.init(name: name, minimumLevel: minimumLevel, writeMode: writeMode)
    }

    @available(*, message: "Deprecation: use other init(name:) init(symbol:) methods instead")
    public init(for applicationName: String, minimumLevel: LogLevel = .info) throws {
        try self.init(name: applicationName, minimumLevel: minimumLevel)
    }

    public init(
        symbol: String = "APP_NAME",
        minimumLevel: LogLevel = .info,
        writeMode: StandardLoggerWriteMode = .append
    ) throws {
        let name = try EnvironmentExtractor.value(.symbol(symbol))
        try self.init(name: name, minimumLevel: minimumLevel, writeMode: writeMode)
    }

    public init(
        symbol: String?,
        minimumLevel: LogLevel = .info,
        writeMode: StandardLoggerWriteMode = .append
    ) throws {
        guard let symbol else {
            throw StandardLoggerError.symbolResolvedToNull
        }
        try self.init(symbol: symbol, minimumLevel: minimumLevel, writeMode: writeMode)
    }

    deinit {
        try? fileHandle?.close()
    }
    
    public func configure(logFileURL: URL, writeMode: StandardLoggerWriteMode = .append) async throws {
        try fileHandle?.close()
        fileHandle = try Self.makeFileHandle(for: logFileURL, writeMode: writeMode)
    }
    
    public func log(_ message: String, level: LogLevel = .info) async {
        guard level >= minimumLevel else { return }

        let ts   = Self.sharedFormatter.value.string(from: Date())
        let line = "[\(ts)] [\(level.label)] \(message)\n"
        guard let data = line.data(using: String.Encoding.utf8) else {
            onError?(StandardLoggerError.failedToWriteLog("UTF-8 encoding failed"))
            return
        }

        do {
            if let fh = fileHandle {
                try fh.write(contentsOf: data)
            } else {
                FileHandle.standardOutput.write(data)
            }
        } catch {
            onError?(StandardLoggerError.failedToWriteLog(error.localizedDescription))
        }
    }
    
    public nonisolated func info(_  message: String) { Task { await log(message, level: .info)  } }
    public nonisolated func warn(_  message: String) { Task { await log(message, level: .warn)  } }
    public nonisolated func error(_ message: String) { Task { await log(message, level: .error) } }
    public nonisolated func critical(_ message: String) { Task { await log(message, level: .critical) } }
    public nonisolated func debug(_ message: String) { Task { await log(message, level: .debug) } }

    // private static let sharedFormatter: ISO8601DateFormatter = {
    //     let f = ISO8601DateFormatter()
    //     f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    //     return f
    // }()

    private static let sharedFormatter = FormatterBox {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }

    private struct FormatterBox<T>: @unchecked Sendable {
        let value: T
        init(_ make: () -> T) { self.value = make() }
    }

    private static func makeFileHandle(
        for url: URL,
        writeMode: StandardLoggerWriteMode
    ) throws -> FileHandle? {
        // guard let url = url else { return nil }
        let dir = url.deletingLastPathComponent()
        let fm = FileManager.default
        try fm.createDirectory(
            at: dir, withIntermediateDirectories: true
        )

        // let created = FileManager.default.createFile(atPath: url.path, contents: nil)
        // guard created || FileManager.default.fileExists(atPath: url.path) else {
        //     throw StandardLoggerError.failedToCreateLogFile(url.path)
        // }

        switch writeMode {
        case .append:
            // Only create the file if missing; do not truncate or touch contents.
            if !fm.fileExists(atPath: url.path) {
                let created = fm.createFile(atPath: url.path, contents: nil)
                guard created else {
                    throw StandardLoggerError.failedToCreateLogFile(url.path)
                }
            }

        case .reset(let options):
            let safe = SafeFile(url)
            _ = try safe.write(Data(), options: options)
        }

        // let fh = try FileHandle(forWritingTo: url)
        // fh.seekToEndOfFile()
        // return fh
        do {
            let fh = try FileHandle(forWritingTo: url)
            fh.seekToEndOfFile()
            return fh
        } catch {
            throw StandardLoggerError.failedToOpenLogFile(url.path)
        }
    }

    public func setLevel(to level: LogLevel) {
        self.minimumLevel = level
    }
}
#endif
