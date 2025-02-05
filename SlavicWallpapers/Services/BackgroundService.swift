import Foundation

actor BackgroundService {
    static let shared = BackgroundService()

    private var timer: Timer?
    private let userDefaults: UserDefaults
    private let updateIntervalKey = "UpdateInterval"

    private init() {
        self.userDefaults = .standard
    }

    var updateInterval: UpdateInterval {
        get {
            guard let data = userDefaults.data(forKey: updateIntervalKey),
                  let interval = try? JSONDecoder().decode(UpdateInterval.self, from: data) else {
                return .default
            }
            return interval
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: updateIntervalKey)
            }
        }
    }

    func startBackgroundUpdates() {
        stopBackgroundUpdates()

        // Проверяем, нужно ли обновить обои
        if shouldUpdateWallpaper() {
            Task {
                await AppState.shared.updateWallpaper()
            }
        }

        // Запускаем таймер
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval.timeInterval, repeats: true) { _ in
            Task {
                await AppState.shared.updateWallpaper()
            }
        }
    }

    private func shouldUpdateWallpaper() -> Bool {
        guard let lastUpdate = userDefaults.object(forKey: "LastWallpaperUpdate") as? Date else {
            return true // Если нет сохраненной даты, обновляем
        }

        let timeSinceLastUpdate = Date().timeIntervalSince(lastUpdate)
        return timeSinceLastUpdate >= updateInterval.timeInterval
    }

    func updateLastUpdateTime() {
        userDefaults.set(Date(), forKey: "LastWallpaperUpdate")
    }

    func stopBackgroundUpdates() {
        timer?.invalidate()
        timer = nil
    }

    func setUpdateInterval(_ interval: UpdateInterval) {
        updateInterval = interval
        // Перезапускаем таймер с новым интервалом
        if timer != nil {
            stopBackgroundUpdates()
            startBackgroundUpdates()
        }
    }
}
