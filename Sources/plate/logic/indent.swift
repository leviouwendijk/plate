import Foundation

public struct StandardIndentation: Sendable {
    public static let size: Int = 4
    public static let times: Int = 1
}

public func indentation(size: Int = 4, times: Int = 1) -> String {
    return String(repeating: " ", count: (size * times))
}

public struct IndentationSetting: Codable, Sendable {
    public var size: Int
    public var times: Int
    public var skip: Bool
    
    public init(
        size: Int = 4,
        times: Int = 1,
        skip: Bool = false
    ) {
        self.size = size
        self.times = times
        self.skip = skip
    }

    public var indent: String {
        return plate.indentation(size: size, times: 1)
    }

    public var indentation: String {
        return plate.indentation(size: size, times: times)
    }
}

public struct IndentationOverride: Codable, Sendable {
    public let index: [Int: IndentationSetting]
    
    public init(
        index: [Int: IndentationSetting]
    ) {
        self.index = index
    }

    public init(
        _ index: [Int: IndentationSetting]
    ) {
        self.index = index
    }
}

public struct IndentationOptions: Codable, Sendable {
    public var size: Int
    public var times: Int
    public var overrides: [IndentationOverride]
    
    public init(
        size: Int = 4,
        times: Int = 1,
        overrides: [IndentationOverride] = []
    ) {
        self.size = size
        self.times = times
        self.overrides = overrides
    }

    public var defaultSetting: IndentationSetting {
        IndentationSetting(size: size, times: times, skip: false)
    }

    public func setting(for index: Int) -> IndentationSetting {
        var setting = defaultSetting

        for override in overrides {
            if let s = override.index[index] {
                setting = s
            }
        }

        return setting
    }
}

public protocol StringIndentable {
    func indent(_ size: Int, times: Int, overrides: [IndentationOverride]) -> String
    func indent(options: IndentationOptions) -> String
}

extension String {
    fileprivate func indenting(with prefix: String) -> String {
        self
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { "\(prefix)\($0)" }
            .joined(separator: "\n")
    }
}

extension String: StringIndentable {
    public func indent(_ size: Int = StandardIndentation.size, times: Int = StandardIndentation.times, overrides: [IndentationOverride] = []) -> String { 
        if overrides.isEmpty {
            let indentation = plate.indentation(size: size, times: times)
            return indenting(with: indentation)
        }

        // Overrides path: split into lines and let the array logic handle it.
        let options = IndentationOptions(
            size: size,
            times: times,
            overrides: overrides
        )

        let lines = self
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)

        return lines.indent(options: options)

        // // let size = indentation * times
        // // let indent = String(repeating: " ", count: size)
        // return self
        //     .split(separator: "\n", omittingEmptySubsequences: false)
        //     // .map { "\(indent)\($0)" }
        //     // .joined(separator: "\n")
        //     .map { "\($0)" }
        //     .indent(size, times: times, overrides: overrides)
    }

    public func indent(options: IndentationOptions = .init()) -> String {
        self.indent(options.size, times: options.times, overrides: options.overrides)
    }
}

extension Array: StringIndentable where Element == String {
    public func indent(
        _ size: Int = StandardIndentation.size,
        times: Int = StandardIndentation.times,
        overrides: [IndentationOverride] = []
    ) -> String {
        let options = IndentationOptions(
            size: size,
            times: times,
            overrides: overrides
        )
        return indent(options: options)
    }

    public func indent(options: IndentationOptions = .init()) -> String {
        self
            .enumerated()
            .map { index, element in
                let setting = options.setting(for: index)

                if setting.skip {
                    return element
                }

                // Important: pass empty overrides here so we don't re-enter override logic per line.
                return element.indent(setting.size, times: setting.times, overrides: [])
            }
            .joined(separator: "\n")
    }
}

// convenience func
public func printi(_ s: String,_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
    print(s.indent(indentation, times: times))
}

public func printindent(_ s: String,_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
    printi(s, indentation, times: times)
}

public func prindent(_ s: String,_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
    printi(s, indentation, times: times)
}

public func printdent(_ s: String,_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
    printi(s, indentation, times: times)
}

// extension mirror
extension String {
    public func printi(_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
        plate.printi(self, indentation, times: times)
    }

    public func printindent(_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
        plate.printi(self, indentation, times: times)
    }

    public func prindent(_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
        plate.printi(self, indentation, times: times)
    }

    public func printdent(_ indentation: Int = StandardIndentation.size, times: Int = StandardIndentation.times) -> Void { 
        plate.printi(self, indentation, times: times)
    }
}
