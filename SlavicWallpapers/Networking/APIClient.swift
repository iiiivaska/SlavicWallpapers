import Foundation

/// Изолированный актор для работы с сетевыми запросами.
///
/// `APIClient` обеспечивает потокобезопасный доступ к сетевым ресурсам,
/// используя систему акторов Swift для синхронизации.
///
/// ## Возможности
/// - Безопасные асинхронные запросы
/// - Изоляция состояния
/// - Обработка сетевых ошибок
///
/// ## Пример использования
/// ```swift
/// let client = APIClient.shared
/// try await client.fetch(endpoint: .randomImage)
/// ```
actor APIClient: APIClientProtocol {
    static let shared = APIClient()

    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    private let baseURL = "http://localhost:8080"

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchRandomPhoto() async throws -> WallpaperResponse {
        let url = URL(string: "\(baseURL)/wallpaper").require()

        var attempts = 0
        while attempts <= NetworkConfig.maxRetryAttempts {
            do {
                let (data, response) = try await session.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw AppError.networkUnavailable
                }

                guard httpResponse.statusCode == 200 else {
                    throw AppError.networkUnavailable
                }

                let wallpaper = try JSONDecoder().decode(WallpaperResponse.self, from: data)
                return wallpaper
            } catch {
                attempts += 1
                if attempts > NetworkConfig.maxRetryAttempts {
                    throw AppError.maxRetryAttemptsReached
                }
                try await Task.sleep(nanoseconds: UInt64(NetworkConfig.retryDelay * 1_000_000_000))
            }
        }
        throw AppError.maxRetryAttemptsReached
    }

    func downloadImage(from urlPath: String) async throws -> Data {
        let fullURL = URL(string: "\(baseURL)\(urlPath)").require()

        var attempts = 0
        while attempts <= NetworkConfig.maxRetryAttempts {
            do {
                let (data, response) = try await session.data(from: fullURL)

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw AppError.networkUnavailable
                }

                return data
            } catch {
                attempts += 1
                if attempts > NetworkConfig.maxRetryAttempts {
                    throw AppError.maxRetryAttemptsReached
                }
                try await Task.sleep(nanoseconds: UInt64(NetworkConfig.retryDelay * 1_000_000_000))
            }
        }
        throw AppError.maxRetryAttemptsReached
    }

    private func performRequest<T: Decodable>(endpoint: UnsplashEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw AppError.networkUnavailable
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.networkUnavailable
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw AppError.imageDownloadFailed
            }

            return try decoder.decode(T.self, from: data)
        } catch is DecodingError {
            throw AppError.invalidImageData
        } catch {
            throw AppError.networkUnavailable
        }
    }
}
