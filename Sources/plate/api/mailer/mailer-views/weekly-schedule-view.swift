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
            .frame(maxWidth: .infinity, alignment: .center)

            VStack {
                ForEach(MailerAPIWeekday.allCases) { day in
                    let isOn = viewModel.schedules[day]?.enabled ?? false

                    HStack(spacing: 12) {
                        StandardToggle(
                            style: .switch,
                            isOn: Binding(
                                get:  { isOn },
                                set: { viewModel.schedules[day]?.enabled = $0 }
                            ),
                            title: day.dutch,
                        )
                        .frame(width: labelWidth, alignment: .leading)

                        Spacer(minLength: 10)

                        // if viewModel.schedules[day]?.enabled == true {
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
                        .opacity(isOn ? 1 : 0)
                        .disabled(!isOn)
                        .animation(.easeInOut(duration: 0.2), value: isOn)
                        // }
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(maxWidth: 500, alignment: .center)
        // .background(
        //     RoundedRectangle(cornerRadius: 8)
        //         .stroke(Color.gray, lineWidth: 1)
        // )
    }
}
