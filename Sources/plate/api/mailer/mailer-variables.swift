import Foundation

// invoice - /issue, /expired, /issue/simple
public struct MailerAPIInvoiceVariables: Encodable {
    public let client_name:   String
    public let email:         String
    public let invoice_id:    String
    public let due_date:      String
    public let product_line:  String
    public let amount:        String
    public let vat_percentage:String
    public let vat_amount:    String
    public let total:         String
    public let terms_total:   String
    public let terms_current: String
}

// lead -- /confirmation, /follow, /check
public struct MailerAPILeadVariables: Encodable {
    public let name:       String
    public let dog:        String

    public let time_range: [String:[String:String]]?
    // public let time_range: MailerAPIAvailabilityContent?
}

// quote -- /issue, /follow
public struct MailerAPIQuoteVariables: Encodable {
    public let name:       String
    public let dog:        String
}

// affiliate -- /food
public struct MailerAPIAffiliateVariables: Encodable {
    public let name:       String
    public let dog:        String
}

// service -- /follow, /onboarding
public struct MailerAPIServiceVariables: Encodable {
    public let name:       String
    public let dog:        String
}

// resolution -- /review, /onboarding
public struct MailerAPIResolutionVariables: Encodable {
    public let name:       String
    public let dog:        String
}

// // custom -- /template/fetch, /message/send
// public struct MailerAPICustomVariables: Encodable {
//     public let category:       String? // for template/fetch
//     public let file:        String? // template/fetch
//     public let body:        String? // message/send
// }
// note: we can handle this in their payload initializers?


// appointment -- /confirmation
public struct MailerAPIAppointmentVariables: Encodable {
    public let name:         String
    public let dog:          String
    public let appointments: [MailerAPIAppointmentContent]

    // public let ics_files:    [String]?  // base64‐encoded ICS blobs
    // handle ICS in payload initializer?
}

// content of appointment var 
public struct MailerAPIAppointmentContent: Encodable {
    public let date:     String
    public let time:     String
    public let day:      String
    public let street:   String
    public let number:   String
    public let area:     String
    public let location: String
}

// time range slot
public struct MailerAPIDayAvailabilityContent: Codable {
    public let start: String
    public let end:   String
}

// output full time_range dictionary
public struct MailerAPIAvailabilityContent: Encodable {
    public let schedule: [MailerAPIWeekday: MailerAPIDayAvailabilityContent]

    public init(from schedules: [MailerAPIWeekday: MailerAPIDaySchedule]) {
        var map: [MailerAPIWeekday: MailerAPIDayAvailabilityContent] = [:]
        let df: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f
        }()
        for (day, sched) in schedules {
            guard sched.enabled else { continue }
            map[day] = .init(
                start: df.string(from: sched.start),
                end:   df.string(from: sched.end)
            )
        }
        self.schedule = map
    }

    public func time_range() -> [String: [String: String]] {
        schedule.reduce(into: [:]) { out, pair in
            let (day, avail) = pair
            out[day.rawValue] = [
                "start": avail.start,
                "end":   avail.end
            ]
        }
    }
}

public enum MailerAPIWeekday: String, RawRepresentable, CaseIterable, Identifiable, Encodable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    public var id: String { rawValue }

    public var dutch: String {
        switch self {
            case .monday: return "Maandag"
            case .tuesday: return "Dinsdag"
            case .wednesday: return "Woensdag"
            case .thursday: return "Donderdag"
            case .friday: return "Vrijdag"
            case .saturday: return "Zaterdag"
            case .sunday: return "Zondag"
        }
    }
}

public struct MailerAPIDaySchedule: Encodable {
    public var enabled: Bool
    public var start:   Date
    public var end:     Date

    public init(defaultsFor day: MailerAPIWeekday) {
        let cal   = Calendar.current
        let today = Date()
        func at(_ hour: Int, _ minute: Int) -> Date {
            return cal.date(
              bySettingHour: hour,
              minute: minute,
              second: 0,
              of: today
            )!
        }

        switch day {
        case .monday:
            enabled = true
            start   = at(18, 0)
            end     = at(21, 0)
        case .tuesday:
            enabled = true
            start   = at(10, 0)
            end     = at(21, 0)
        case .wednesday:
            enabled = true
            start   = at(18, 0)
            end     = at(21, 0)
        case .thursday:
            enabled = true
            start   = at(18, 0)
            end     = at(21, 0)
        case .friday:
            enabled = true
            start   = at(10, 0)
            end     = at(21, 0)
        case .saturday:
            enabled = true
            start   = at(18, 0)
            end     = at(21, 0)
        case .sunday:
            enabled = true
            start   = at(18, 0)
            end     = at(21, 0)
        }
    }
}
