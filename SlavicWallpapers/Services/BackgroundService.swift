import Foundation

protocol AppStateProtocol {
    func updateWallpaper() async
}

extension AppState: AppStateProtocol {}

actor BackgroundService {
    static let shared = BackgroundService()

    private let userDefaults: UserDefaults
    private let appState: AppStateProtocol
    private let updateIntervalKey = "UpdateInterval"
    private let checkInterval: TimeInterval = 60 // Проверяем каждую минуту
    private let lastUpdateKey = "LastWallpaperUpdate"

    @MainActor
    private var mainTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    private init() {
        self.userDefaults = .standard
        self.appState = AppState.shared // Инициализируем сразу, так как shared уже @MainActor
    }

    // Internal for testing
    init(userDefaults: UserDefaults, appState: AppStateProtocol) {
        self.userDefaults = userDefaults
        self.appState = appState
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

    func startBackgroundUpdates() async {
        await stopBackgroundUpdates()

        // Проверяем при запуске
        if shouldUpdateWallpaper() {
            await appState.updateWallpaper()
            updateLastUpdateTime()
        }

        await startTimer()
    }

    @MainActor
    private func startTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                if await self.shouldUpdateWallpaper() {
                    await self.appState.updateWallpaper()
                    await self.updateLastUpdateTime()
                }
            }
        }
        mainTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func shouldUpdateWallpaper() -> Bool {
        guard let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date else {
            return true // Если нет сохраненной даты, нужно обновить
        }

        let now = Date()
        let timeSinceLastUpdate = now.timeIntervalSince(lastUpdate)
        let nextUpdateTime = lastUpdate.addingTimeInterval(updateInterval.timeInterval)

        return now >= nextUpdateTime && timeSinceLastUpdate >= updateInterval.timeInterval
    }

    func updateLastUpdateTime() {
        userDefaults.set(Date(), forKey: lastUpdateKey)
    }

    @MainActor
    func stopBackgroundUpdates() {
        mainTimer = nil
    }

    func setUpdateInterval(_ interval: UpdateInterval) async {
        updateInterval = interval
        // Перезапускаем таймер с новым интервалом
        let hasTimer = await MainActor.run { self.mainTimer != nil }
        if hasTimer {
            await stopBackgroundUpdates()
            await startBackgroundUpdates()
        }
    }

    // Internal for testing purposes only
    var isTimerActive: Bool {
        get async {
            await MainActor.run { self.mainTimer != nil }
        }
    }
}
