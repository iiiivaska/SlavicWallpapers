import Foundation

/// Интервал автоматического обновления обоев.
///
/// Определяет периодичность смены обоев в фоновом режиме.
///
/// ## Пример использования
/// ```swift
/// let interval = UpdateInterval(hours: 1, minutes: 30)
/// appState.setUpdateInterval(interval)
/// ```
struct UpdateInterval: Codable, Equatable {
    let hours: Int
    let minutes: Int

    var timeInterval: TimeInterval {
        TimeInterval(hours * 3600 + minutes * 60)
    }

    static let `default` = UpdateInterval(hours: 1, minutes: 0)

    var isValid: Bool {
        true
    }
}
