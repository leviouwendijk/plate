import SwiftUI
import Combine

/// A reusable weekly schedule view that binds to a shared ViewModel
public struct WeeklyScheduleView: View {
    @ObservedObject public var viewModel: WeeklyScheduleViewModel
    public var labelWidth: CGFloat

    public init(
        viewModel: WeeklyScheduleViewModel,
        labelWidth: CGFloat = 150
    ) {
        self.viewModel = viewModel
        self.labelWidth = labelWidth
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "Availability", width: labelWidth)
            .frame(alignment: .center)

            VStack {
                ForEach(MailerAPIWeekday.allCases) { day in
                    HStack(spacing: 12) {
                        StandardToggle(
                            style: .switch,
                            isOn: Binding(
                                get:  { viewModel.schedules[day]?.enabled ?? false },
                                set: { viewModel.schedules[day]?.enabled = $0 }
                            ),
                            title: day.dutch,
                        )
                        .frame(width: labelWidth, alignment: .leading)

                        if viewModel.schedules[day]?.enabled == true {
                            StandardTimeRow(
                                // title: day.dutch,
                                start: Binding(
                                    get:  { viewModel.schedules[day]?.start ?? Date() },
                                    set: { viewModel.schedules[day]?.start = $0 }
                                ),
                                end: Binding(
                                    get:  { viewModel.schedules[day]?.end ?? Date() },
                                    set: { viewModel.schedules[day]?.end = $0 }
                                )
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}
