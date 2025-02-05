import SwiftUI

/// Главное состояние приложения, управляющее всеми основными функциями.
///
/// `AppState` является единственным источником истины для состояния приложения,
/// реализуя паттерн Singleton для глобального доступа.
///
/// ## Основные возможности
/// - Управление режимом обоев
/// - Контроль фонового обновления
/// - Обработка ошибок
/// - Управление интервалом обновления
///
/// ## Пример использования
/// ```swift
/// let appState = AppState.shared
/// await appState.updateWallpaper()
/// ```
@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isUpdating = false
    @Published var lastUpdate: Date?
    @Published var error: String?
    @Published var isBackgroundEnabled = true
    @Published private(set) var wallpaperMode: WallpaperMode = .same
    @Published private(set) var updateInterval: UpdateInterval = .default
    @Published var showingIntervalPicker = false

    private init() {
        // Загружаем сохраненный режим обоев
        Task {
            self.wallpaperMode = await WallpaperManager.shared.getCurrentMode()
        }
    }

    func updateWallpaper() {
        guard !isUpdating else { return }

        isUpdating = true
        error = nil

        Task {
            do {
                // Используем WallpaperManager для установки обоев с учетом режима
                let imageUrl = try await ImageService.shared.downloadAndCacheImage()
                try await WallpaperManager.shared.setWallpaper(from: imageUrl)

                self.isUpdating = false
                self.lastUpdate = Date()
                Task {
                    await BackgroundService.shared.updateLastUpdateTime()
                }
            } catch let error as AppError {
                self.isUpdating = false
                self.error = error.localizedDescription
            } catch {
                self.isUpdating = false
                self.error = Localizable.Error.unknown
            }
        }
    }

    func openWallpapersFolder() {
        Task {
            let urls = await ImageService.shared.getCachedImages()
            if let firstImage = urls.first {
                await MainActor.run {
                    NSWorkspace.shared.selectFile(
                        firstImage.path,
                        inFileViewerRootedAtPath: firstImage.deletingLastPathComponent().path
                    )
                }
            }
        }
    }

    func toggleBackgroundUpdates() {
        isBackgroundEnabled.toggle()
        Task {
            if isBackgroundEnabled {
                await BackgroundService.shared.startBackgroundUpdates()
            } else {
                await BackgroundService.shared.stopBackgroundUpdates()
            }
        }
    }

    func setWallpaperMode(_ mode: WallpaperMode) async {
        guard !isUpdating else { return }

        isUpdating = true
        error = nil
        do {
            await WallpaperManager.shared.setMode(mode)
            self.wallpaperMode = mode

            // Обновляем обои сразу после смены режима
            let imageUrl = try await ImageService.shared.downloadAndCacheImage()
            try await WallpaperManager.shared.setWallpaper(from: imageUrl)

            self.isUpdating = false
            self.lastUpdate = Date()
        } catch {
            self.isUpdating = false
            self.error = error.localizedDescription
        }
    }

    func setUpdateInterval(_ interval: UpdateInterval) async {
        await BackgroundService.shared.setUpdateInterval(interval)
        self.updateInterval = interval
    }
}
