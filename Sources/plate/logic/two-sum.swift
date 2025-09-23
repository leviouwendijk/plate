import Foundation

public enum PlateTwoSumError: Error, LocalizedError {
    case noMatchingTarget(target: Int)

    public var errorDescription: String? {
        switch self {
            case .noMatchingTarget(let target):
                return "No matching numbers in array for sought target of \(target)"
        }
    }
}

public func twoSum(_ nums: [Int], _ target: Int) throws -> [(index: Int, value: Int)] {
    var seen = [Int: Int]()
    var matches = [(index: Int, value: Int)]()

    for (i, num) in nums.enumerated() {
        let diff = target - num 
        if let match = seen[diff] {
            matches.append( (index: match, value: diff) )
            matches.append( (index: i, value: num) )
        }
        seen[num] = i
    }
    
    if matches.isEmpty {
        throw PlateTwoSumError.noMatchingTarget(target: target)
    }

    return matches
}

public func twoSum(_ nums: [Int], _ target: Int) throws -> [[Int]] {
    var seen = [Int: Int]()
    var matches = [[Int]]()

    for (i, num) in nums.enumerated() {
        let diff = target - num 
        if let match = seen[diff] {
            matches.append([match, i])
        }
        seen[num] = i
    }
    
    if matches.isEmpty {
        throw PlateTwoSumError.noMatchingTarget(target: target)
    }

    return matches
}
