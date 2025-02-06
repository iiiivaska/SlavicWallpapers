import Foundation

/// Сервис для работы с изображениями.
///
/// Управляет загрузкой, кэшированием и хранением изображений.
///
/// ## Возможности
/// - Загрузка изображений
/// - Локальное кэширование
/// - Управление хранилищем
///
/// ## Пример использования
/// ```swift
/// let service = ImageService.shared
/// let imageUrl = try await service.downloadAndCacheImage()
/// ```
actor ImageService {
    static let shared = ImageService()

    private let fileManager: FileManager
    private let cachesDirectory: URL
    private let maxCacheSize: Int = 500 * 1024 * 1024 // 500 MB
    private let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 7 дней

    private init() {
        self.fileManager = FileManager.default

        guard let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Unable to access caches directory")
        }

        self.cachesDirectory = cachesDir.appendingPathComponent("SlavicWallpapers", isDirectory: true)

        try? fileManager.createDirectory(at: cachesDirectory, withIntermediateDirectories: true)

        // Очищаем старый кэш при запуске
        Task {
            try? await cleanOldCache()
        }
    }

    func downloadAndCacheImage() async throws -> URL {
        do {
            try await maintainCache()
            
            let photo = try await APIClient.shared.fetchRandomPhoto()
            
            // Получаем только путь из imageURL
            let imageData = try await APIClient.shared.downloadImage(from: photo.imageURL)
            
            let fileName = "\(photo.id)_\(Date().timeIntervalSince1970).jpg"
            let fileURL = cachesDirectory.appendingPathComponent(fileName)
            
            do {
                try imageData.write(to: fileURL)
            } catch {
                throw AppError.cacheSaveFailed
            }
            
            return fileURL
        } catch {
            throw error
        }
    }

    private func maintainCache() async throws {
        let cacheSize = try await calculateCacheSize()
        if cacheSize > maxCacheSize {
            try await cleanOldCache()
        }
    }

    private func calculateCacheSize() async throws -> Int {
        let contents = try fileManager.contentsOfDirectory(
            at: cachesDirectory, includingPropertiesForKeys: [.fileSizeKey]
        )
        return try contents.reduce(0) { sum, url in
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            return sum + (resourceValues.fileSize ?? 0)
        }
    }

    private func cleanOldCache() async throws {
        let contents = try fileManager.contentsOfDirectory(
            at: cachesDirectory, includingPropertiesForKeys: [.creationDateKey]
        )
        let oldFiles = contents.filter { url in
            guard let creationDate = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate else {
                return false
            }
            return Date().timeIntervalSince(creationDate) > maxCacheAge
        }

        for url in oldFiles {
            try? fileManager.removeItem(at: url)
        }
    }

    func getCachedImages() async -> [URL] {
        (try? fileManager.contentsOfDirectory(
            at: cachesDirectory,
            includingPropertiesForKeys: [.creationDateKey]
        )
        .sorted { url1, url2 in
            guard let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate,
                  let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate else {
                return false
            }
            return date1 > date2
        }) ?? []
    }

    func clearCache() throws {
        let contents = try fileManager.contentsOfDirectory(at: cachesDirectory, includingPropertiesForKeys: nil)
        for url in contents {
            try fileManager.removeItem(at: url)
        }
    }
}
