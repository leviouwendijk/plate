import Foundation

public actor StandardLogger {
    public var minimumLevel: LogLevel
    public var onError: ((Error) -> Void)?
    
    public init(
        logFileURL: URL,
        minimumLevel: LogLevel = .info
    ) throws {
        self.fileHandle = try Self.makeFileHandle(for: logFileURL)
        self.minimumLevel = minimumLevel
    }
    
    public init(
        name: String,
        minimumLevel: LogLevel = .info
    ) throws {
        let url = Home.url()
        .appendingPathComponent("api-logs")
        .appendingPathComponent("\(name).log")

        self.fileHandle = try Self.makeFileHandle(for: url)
        self.minimumLevel = minimumLevel
    }

    public init(
        name: String?,
        minimumLevel: LogLevel = .info
    ) throws {
        guard let name else {
            throw StandardLoggerError.appNameEmpty
        }
        try self.init(name: name, minimumLevel: minimumLevel)
    }

    @available(*, message: "Deprecation: use other init(name:) init(symbol:) methods instead")
    public init(for applicationName: String, minimumLevel: LogLevel = .info) throws {
        try self.init(name: applicationName, minimumLevel: minimumLevel)
    }

    public init(
        symbol: String = "APP_NAME",
        minimumLevel: LogLevel = .info
    ) throws {
        let name = try EnvironmentExtractor.value(.symbol(symbol))
        try self.init(name: name, minimumLevel: minimumLevel)
    }

    public init(
        symbol: String?,
        minimumLevel: LogLevel = .info
    ) throws {
        guard let symbol else {
            throw StandardLoggerError.symbolResolvedToNull
        }
        try self.init(symbol: symbol, minimumLevel: minimumLevel)
    }

    deinit {
        try? fileHandle?.close()
    }
    
    public func configure(logFileURL: URL) async throws {
        try fileHandle?.close()
        fileHandle = try Self.makeFileHandle(for: logFileURL)
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
    public nonisolated func debug(_ message: String) { Task { await log(message, level: .critical) } }

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

    private var fileHandle: FileHandle?

    private static func makeFileHandle(for url: URL) throws -> FileHandle? {
        // guard let url = url else { return nil }
        let dir = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: dir, withIntermediateDirectories: true
        )

        let created = FileManager.default.createFile(atPath: url.path, contents: nil)
        guard created || FileManager.default.fileExists(atPath: url.path) else {
            throw StandardLoggerError.failedToCreateLogFile(url.path)
        }

        // let fh = try FileHandle(forWritingTo: url)
        // fh.seekToEndOfFile()
        // return fh
        do {
            let fh = try FileHandle(forWritingTo: url)
            fh.seekToEndOfFile()
            return fh
        } catch {
            throw StandardLoggerError.failedToCloseFile(error.localizedDescription)
        }
    }

    public func setLevel(to level: LogLevel) {
        self.minimumLevel = level
    }
}
