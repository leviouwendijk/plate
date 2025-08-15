import Foundation

public struct ReadableErrorHandler: Sendable {
    public var context: Int
    public var useColor: Bool

    public init(context: Int = 6, useColor: Bool = true) {
        self.context = context
        self.useColor = useColor
    }

    /// Decodes two JSON arrays-of-strings and prints a colored, contextual diff.
    /// Returns true when equal, false otherwise.
    @discardableResult
    public func diffTokens(
        expected: Data,
        actual: Data,
        atPath: String,
        lineForIndex: ((Int) -> Int)? = nil
    ) -> Bool {
        guard
            let e = try? JSONSerialization.jsonObject(with: expected) as? [String],
            let a = try? JSONSerialization.jsonObject(with: actual)   as? [String]
        else {
            return expected == actual
        }
        if e == a { return true }
        printTokenArrayDiff(exp: e, act: a, atPath: atPath, lineForIndex: lineForIndex)
        return false
    }

    /// Parses arbitrary JSON (objects/arrays) and shows first differing JSONPath
    /// with pretty-printed, colored expected vs actual. Returns true when equal.
    // === JSON diff: add spacing + arrow summary ===
    @discardableResult
    public func diffJSON(expected: Data, actual: Data, atPath: String) -> Bool {
        func parse(_ d: Data) -> Any? { try? JSONSerialization.jsonObject(with: d, options: []) }
        guard let e = parse(expected), let a = parse(actual) else { return expected == actual }
        if deepEqual(e, a) { return true }
        if let (path, ev, av) = firstDiff(e, a) {
            let hdr = indent("first differing path: \(cc(path, .cyan))")
            print(hdr)
            print(indent("expected: \(pretty(ev))"))
            print("") // spacing
            print(indent("  actual: \(pretty(av))"))
            print("") // spacing
            print(indent("-->> \(cc(pretty(ev), .yellow))  \(cc("→", .bold))  \(cc(pretty(av), .yellow))"))
        }
        return false
    }

    // === Tokens diff: add spacing + optional line + arrow summary ===
    private func printTokenArrayDiff(
        exp e: [String],
        act a: [String],
        atPath: String,
        lineForIndex: ((Int) -> Int)?
    ) {
        let i = firstIndexOfDifference(e, a) ?? min(e.count, a.count)
        let start = max(0, i - context)
        let endE  = min(e.count, i + context + 1)
        let endA  = min(a.count, i + context + 1)

        let lineTag: String = {
            if let ln = lineForIndex?(i) { return "[\(ln)]" }
            return "[tok \(i)]"
        }()

        print(indent("first differing index: \(i)"))

        print(indent("… expected[\(start)..<\(endE)]:"))
        print(indent(renderSlice(e, start..<endE, highlightAt: i)))
        print("") // spacing

        print(indent("…   actual[\(start)..<\(endA)]:"))
        print(indent(renderSlice(a, start..<endA, highlightAt: i)))
        print("") // spacing

        // short summary lines
        let expTok = i < e.count ? e[i] : cc("<missing>", .red)
        let actTok = i < a.count ? a[i] : cc("<missing>", .red)
        print(indent("\(lineTag): -->> \(cc(expTok, .brightYellow))"))
        print(indent("\(lineTag): -->> \(cc(expTok, .yellowBackground, .black))"))
        print(indent("\(lineTag): -->> \(cc(actTok, .yellow))"))
    }

    private func renderSlice(_ arr: [String], _ range: Range<Int>, highlightAt hi: Int) -> String {
        var out: [String] = []
        for idx in range {
            let t = arr[idx]
            if idx == hi {
                // choose your style:
                // out.append(cc(t, .bold, .brightRedBackground, .white)) // strong highlight
                out.append(cc(t, .bold, .red)) // simpler highlight
            } else {
                out.append(t)
            }
        }
        return out.joined(separator: " ")
    }

    private func firstIndexOfDifference(_ e: [String], _ a: [String]) -> Int? {
        let n = min(e.count, a.count)
        var i = 0
        while i < n && e[i] == a[i] { i += 1 }
        return (i < n || e.count != a.count) ? i : nil
    }

    // Generic JSON diff helpers (first difference)
    private func deepEqual(_ x: Any, _ y: Any) -> Bool {
        switch (x, y) {
        case let (dx as [String: Any], dy as [String: Any]):
            if Set(dx.keys) != Set(dy.keys) { return false }
            for k in dx.keys { if !deepEqual(dx[k]!, dy[k]!) { return false } }
            return true
        case let (ax as [Any], ay as [Any]):
            guard ax.count == ay.count else { return false }
            for i in 0..<ax.count { if !deepEqual(ax[i], ay[i]) { return false } }
            return true
        case let (sx as String, sy as String): return sx == sy
        case let (nx as NSNumber, ny as NSNumber): return nx == ny
        case (_ as NSNull, _ as NSNull): return true
        default: return false
        }
    }

    private func firstDiff(_ x: Any, _ y: Any, path: String = "$") -> (String, Any, Any)? {
        switch (x, y) {
        case let (dx as [String: Any], dy as [String: Any]):
            let keys = Array(Set(dx.keys).union(dy.keys)).sorted()
            for k in keys {
                let xv = dx[k], yv = dy[k]
                if xv == nil { return ("\(path).\(k)", NSNull(), yv as Any) }
                if yv == nil { return ("\(path).\(k)", xv as Any, NSNull()) }
                if let d = firstDiff(xv as Any, yv as Any, path: "\(path).\(k)") { return d }
            }
            return nil
        case let (ax as [Any], ay as [Any]):
            let n = min(ax.count, ay.count)
            for i in 0..<n {
                if let d = firstDiff(ax[i], ay[i], path: "\(path)[\(i)]") { return d }
            }
            if ax.count != ay.count { return ("\(path).length", ax.count, ay.count) }
            return nil
        default:
            return deepEqual(x, y) ? nil : (path, x, y)
        }
    }

    // Pretty + ANSI
    private func pretty(_ v: Any) -> String {
        if let s = v as? String {
            let escaped = s
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            return cc("\"\(escaped)\"", .yellow)
        }
        if let n = v as? NSNumber { return cc(n.stringValue, .yellow) }
        if v is NSNull { return cc("null", .yellow) }

        if let dict = v as? [String: Any],
           let d = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys]),
           let s = String(data: d, encoding: .utf8) {
            return cc(s, .yellow)
        }
        if let arr = v as? [Any],
           let d = try? JSONSerialization.data(withJSONObject: arr, options: [.sortedKeys]),
           let s = String(data: d, encoding: .utf8) {
            return cc(s, .yellow)
        }
        if let d = try? JSONSerialization.data(withJSONObject: v, options: [.fragmentsAllowed]),
           let s = String(data: d, encoding: .utf8) {
            return cc(s, .yellow)
        }
        return cc(String(describing: v), .yellow)
    }

    private func indent(_ s: String) -> String { "      " + s }

    // Bridge to your existing ANSI helpers without needing an array overload.
    private func cc(_ s: String, _ colors: ANSIColor...) -> String {
        guard useColor, !colors.isEmpty else { return s }
        let prefix = colors.map { $0.rawValue }.joined()
        return "\(prefix)\(s)\(ANSIColor.reset.rawValue)"
    }
}
