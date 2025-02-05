import Foundation

/// Интервал автоматического обновления обоев.
///
/// Определяет периодичность смены обоев в фоновом режиме.
///
/// ## Ограничения
/// - Минимум: 30 минут
/// - Максимум: 24 часа
///
/// ## Пример использования
/// ```swift
/// let interval = UpdateInterval(hours: 2, minutes: 30)
/// await appState.setUpdateInterval(interval)
/// ```
struct UpdateInterval: Codable, Equatable {
    var hours: Int
    var minutes: Int

    var timeInterval: TimeInterval {
        TimeInterval(hours * 3600 + minutes * 60)
    }

    var localizedDescription: String {
        if hours == 0 {
            return String(format: Localizable.Time.minutesOnly, minutes)
        } else if minutes == 0 {
            return String(format: Localizable.Time.hoursOnly, hours)
        } else {
            return String(format: Localizable.Time.hoursAndMinutes, hours, minutes)
        }
    }

    static let `default` = UpdateInterval(hours: 24, minutes: 0)
    static let minimum = UpdateInterval(hours: 0, minutes: 30)
}
