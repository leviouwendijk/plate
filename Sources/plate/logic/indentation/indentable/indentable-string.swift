import Foundation

extension String {
    fileprivate func indenting(with prefix: String) -> String {
        self
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { "\(prefix)\($0)" }
            .joined(separator: "\n")
    }
}

extension String: Indentable {
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
