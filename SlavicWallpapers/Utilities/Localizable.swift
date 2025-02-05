import Foundation

/// Централизованное хранилище локализованных строк.
///
/// Обеспечивает доступ ко всем локализованным строкам приложения.
///
/// ## Разделы
/// - General: Общие строки
/// - Menu: Элементы меню
/// - Error: Сообщения об ошибках
/// - Time: Временные метки
///
/// ## Пример использования
/// ```swift
/// Text(Localizable.Menu.updateWallpaper)
/// ```
enum Localizable {
    enum General {
        static let appName = NSLocalizedString("app.name", comment: "Application name")
        static let version = NSLocalizedString("app.version", comment: "Application version")
    }

    enum Menu {
        static let updateWallpaper = NSLocalizedString("menu.update_wallpaper",
                                                       comment: "Update wallpaper button")
        static let openFolder = NSLocalizedString("menu.open_folder",
                                                  comment: "Open wallpapers folder button")
        static let backgroundUpdate = NSLocalizedString("menu.background_update",
                                                        comment: "Background update toggle")
        static let quit = NSLocalizedString("menu.quit", comment: "Quit application button")
        static let lastUpdate = NSLocalizedString("menu.last_update",
                                                  comment: "Last update time label")
        static let wallpaperMode = NSLocalizedString("menu.wallpaper_mode",
                                                     comment: "Wallpaper mode menu")
    }

    enum Error {
        static let networkUnavailable = NSLocalizedString("error.network_unavailable",
                                                          comment: "No internet connection")
        static let imageDownloadFailed = NSLocalizedString("error.download_failed",
                                                           comment: "Failed to download image")
        static let invalidImageData = NSLocalizedString("error.invalid_image",
                                                        comment: "Invalid image data")
        static let cacheSaveFailed = NSLocalizedString("error.cache_save_failed",
                                                       comment: "Failed to save image")
        static let wallpaperSetFailed = NSLocalizedString("error.wallpaper_set_failed",
                                                          comment: "Failed to set wallpaper")
        static let maxRetryAttemptsReached = NSLocalizedString("error.max_retry_reached",
                                                               comment: "Max retry attempts reached")
        static let unknown = NSLocalizedString("error.unknown",
                                               comment: "Unknown error occurred")
        static let fileNotFound = NSLocalizedString("error.file_not_found",
                                                    comment: "Wallpaper file not found")
    }

    enum Time {
        static let hoursOnly = NSLocalizedString("time.hours_only",
                                                 comment: "Hours only format")
        static let minutesOnly = NSLocalizedString("time.minutes_only",
                                                   comment: "Minutes only format")
        static let hoursAndMinutes = NSLocalizedString("time.hours_and_minutes",
                                                       comment: "Hours and minutes format")
        static let updateInterval = NSLocalizedString("update_interval", comment: "Update interval title")
        static let hours = NSLocalizedString("hours", comment: "Hours")
        static let minutes = NSLocalizedString("minutes", comment: "Minutes")
        static let hour = NSLocalizedString("hour", comment: "Single hour")
        static let minute = NSLocalizedString("minute", comment: "Single minute")
        static let every = NSLocalizedString("every", comment: "Every time period")
        static let updateIntervalWithTime = NSLocalizedString(
            "update_interval_with_time",
            comment: "Update interval with time description"
        )
        static let updateIntervalTitle = NSLocalizedString(
            "update_interval_title",
            comment: "Update interval selection title"
        )
    }
}
