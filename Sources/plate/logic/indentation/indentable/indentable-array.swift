import Foundation

extension Array: Indentable where Element == String {
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
