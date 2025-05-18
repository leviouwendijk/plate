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
            SectionTitle(title: "Availability", width: 150)

            ForEach(MailerAPIWeekday.allCases) { day in
                HStack(spacing: 12) {
                    Toggle(day.dutch, isOn: Binding(
                        get:  { viewModel.schedules[day]?.enabled ?? false },
                        set: { viewModel.schedules[day]?.enabled = $0 }
                    ))
                    .toggleStyle(SwitchToggleStyle())
                    .frame(width: labelWidth, alignment: .leading)

                    if viewModel.schedules[day]?.enabled == true {
                        DatePicker(
                            "",
                            selection: Binding(
                                get:  { viewModel.schedules[day]?.start ?? Date() },
                                set: { viewModel.schedules[day]?.start = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .datePickerStyle(CompactDatePickerStyle())

                        DatePicker(
                            "",
                            selection: Binding(
                                get:  { viewModel.schedules[day]?.end ?? Date() },
                                set: { viewModel.schedules[day]?.end = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .datePickerStyle(CompactDatePickerStyle())
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
