import SwiftUI

struct UpdateIntervalView: View {
    @Binding var interval: UpdateInterval
    let onDismiss: () -> Void

    @State private var hours: Double
    @State private var minutes: Double

    init(interval: Binding<UpdateInterval>, onDismiss: @escaping () -> Void) {
        self._interval = interval
        self.onDismiss = onDismiss
        self._hours = State(initialValue: Double(interval.wrappedValue.hours))
        self._minutes = State(initialValue: Double(interval.wrappedValue.minutes))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(Localizable.Time.updateInterval)
                .font(.headline)

            VStack(spacing: 12) {
                IntervalSlider(
                    value: $hours,
                    range: 0...24,
                    step: 1,
                    title: Localizable.Time.hours
                )
                .accessibilityIdentifier("hoursSlider")

                IntervalSlider(
                    value: $minutes,
                    range: 0...59,
                    step: 5,
                    title: Localizable.Time.minutes
                )
                .accessibilityIdentifier("minutesSlider")
            }
            .padding()

            Text(getCurrentIntervalDescription())
                .foregroundColor(.secondary)

            HStack {
                Button("OK") {
                    interval = calculateInterval()
                    onDismiss()
                }
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("okButton")

                Button("Cancel") {
                    onDismiss()
                }
                .keyboardShortcut(.cancelAction)
                .accessibilityIdentifier("cancelButton")
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 300)
    }

    private func getCurrentIntervalDescription() -> String {
        let currentInterval = UpdateInterval(hours: Int(hours), minutes: Int(minutes))
        return StringFormatting.intervalDescription(for: currentInterval)
    }

    private func calculateInterval() -> UpdateInterval {
        UpdateInterval(hours: Int(hours), minutes: Int(minutes))
    }
}

private struct IntervalSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value))")
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            .font(.subheadline)

            Slider(value: $value, in: range, step: step)
                .tint(.blue)
                .animation(.spring(duration: 0.2), value: value)
        }
    }
}

#Preview {
    UpdateIntervalView(
        interval: .constant(UpdateInterval(hours: 1, minutes: 0)),
        onDismiss: {}
    )
}
