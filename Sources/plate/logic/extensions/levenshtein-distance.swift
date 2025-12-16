import Foundation

extension String {
    public func levenshteinDistance(to target: String) -> Int {
        let s = Array(self)
        let t = Array(target)
        let m = s.count, n = t.count

        if m == 0 { return n }
        if n == 0 { return m }

        // self[0..<i-1] and target[0..<j]
        var prev = Array(0...n)
        var curr = [Int](repeating: 0, count: n + 1)

        for i in 1...m {
            curr[0] = i
            for j in 1...n {
                let cost = (s[i-1] == t[j-1]) ? 0 : 1
                // deletion:   prev[j] + 1
                // insertion:  curr[j-1] + 1
                // substitution: prev[j-1] + cost
                curr[j] = Swift.min(
                    prev[j]     + 1,
                    curr[j-1]   + 1,
                    prev[j-1]   + cost
                )
            }
            // roll the rows
            (prev, curr) = (curr, prev)
        }
        return prev[n]
    }
}
