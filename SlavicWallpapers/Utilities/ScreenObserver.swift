import AppKit

class ScreenObserver: ObservableObject {
    static let shared = ScreenObserver()

    @Published var screensCount = NSScreen.screens.count

    private init() {
        // Наблюдаем за изменениями экранов
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc private func screensDidChange() {
        DispatchQueue.main.async {
            self.screensCount = NSScreen.screens.count
        }
    }
}
