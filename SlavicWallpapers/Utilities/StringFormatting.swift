import Foundation

enum StringFormatting {
    static func pluralForm(for number: Int, one: String, few: String, many: String) -> String {
        let mod10 = number % 10
        let mod100 = number % 100

        if mod10 == 1 && mod100 != 11 {
            return one
        }

        if (2...4).contains(mod10) && !(12...14).contains(mod100) {
            return few
        }

        return many
    }

    static func hoursString(for hours: Int) -> String {
        return pluralForm(
            for: hours,
            one: Localizable.Time.hour,      // "час"
            few: "часа",                     // 2-4 часа
            many: Localizable.Time.hours      // "часов"
        )
    }

    static func minutesString(for minutes: Int) -> String {
        return pluralForm(
            for: minutes,
            one: Localizable.Time.minute,     // "минута"
            few: "минуты",                    // 2-4 минуты
            many: Localizable.Time.minutes    // "минут"
        )
    }

    static func intervalDescription(for interval: UpdateInterval) -> String {
        if interval.hours == 0 {
            return "\(Localizable.Time.every) \(interval.minutes) \(minutesString(for: interval.minutes))"
        } else if interval.minutes == 0 {
            return "\(Localizable.Time.every) \(interval.hours) \(hoursString(for: interval.hours))"
        }

        return "\(Localizable.Time.every) \(interval.hours) \(hoursString(for: interval.hours)) " +
            "\(interval.minutes) \(minutesString(for: interval.minutes))"
    }

    static func menuIntervalDescription(for interval: UpdateInterval) -> String {
        String(format: Localizable.Time.updateIntervalWithTime, intervalDescription(for: interval))
    }
}
