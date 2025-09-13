import Foundation

public func multiple(_ target: Int, of multiple: Int) -> Bool {
    return (target % multiple) == 0
}

extension Int {
    public func multiple(of num: Int) -> Bool {
        return plate.multiple(self, of: num)
    }
}
