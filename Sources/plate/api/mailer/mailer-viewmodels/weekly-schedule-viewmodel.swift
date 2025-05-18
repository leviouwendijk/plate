import SwiftUI
import Combine

public class WeeklyScheduleViewModel: ObservableObject {
    @Published public var schedules: [MailerAPIWeekday: MailerAPIDaySchedule]

    public init(
        schedules: [MailerAPIWeekday: MailerAPIDaySchedule]? = nil
    ) {
        let base = Dictionary(
            uniqueKeysWithValues: MailerAPIWeekday.allCases.map {
                ($0, MailerAPIDaySchedule(defaultsFor: $0))
            }
        )
        self.schedules = schedules ?? base
    }

    /// Convenience to get Encodable availability content
    public var availabilityContent: MailerAPIAvailabilityContent {
        MailerAPIAvailabilityContent(from: schedules)
    }
}
