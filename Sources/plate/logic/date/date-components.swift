import Foundation

public func seconds(_ count: Int = 1) -> DateComponents {
    var dc = DateComponents()
    dc.second = count
    return dc
}

public func minutes(_ count: Int = 1) -> DateComponents {
    var dc = DateComponents()
    dc.minute = count
    return dc
}

public func hours(_ count: Int = 1) -> DateComponents {
    var dc = DateComponents()
    dc.hour = count
    return dc
}

public func days(_ count: Int = 1) -> DateComponents {
    var dc = DateComponents()
    dc.day = count
    return dc
}

public func weeks(_ count: Int = 1) -> DateComponents {
    var dc = DateComponents()
    dc.weekOfYear = count
    return dc
}

public func months(_ count: Int = 1) -> DateComponents {
    var dc = DateComponents()
    dc.month = count
    return dc
}

public func years(_ count: Int = 1) -> DateComponents {
    var dc = DateComponents()
    dc.year = count
    return dc
}

extension Int {
    public var seconds: DateComponents { plate.seconds(self) }
    public var minutes: DateComponents { plate.minutes(self) }
    public var hours:   DateComponents { plate.hours(self)   }
    public var days:    DateComponents { plate.days(self)    }
    public var weeks:   DateComponents { plate.weeks(self)   }
    public var months:  DateComponents { plate.months(self)  }
    public var years:   DateComponents { plate.years(self)   }
}

public extension Date {
    static func + (lhs: Date, rhs: DateComponents) -> Date {
        Calendar.current.date(byAdding: rhs, to: lhs)!
    }
}
