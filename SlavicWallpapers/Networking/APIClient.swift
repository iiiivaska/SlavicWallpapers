import Foundation

actor APIClient: APIClientProtocol {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = NetworkConfig.defaultTimeout
        config.timeoutIntervalForResource = NetworkConfig.defaultTimeout
        config.httpAdditionalHeaders = [
            NetworkConfig.Headers.authorization: "\(NetworkConfig.Headers.clientId) \(APIConfig.unsplashAccessKey)",
            NetworkConfig.Headers.contentType: NetworkConfig.ContentType.json,
            NetworkConfig.Headers.accept: NetworkConfig.ContentType.json
        ]
        
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }
    
    func fetchRandomPhoto(retryCount: Int = 0) async throws -> UnsplashPhoto {
        do {
            return try await fetchRandomPhotoInternal()
        } catch {
            if retryCount < NetworkConfig.maxRetryAttempts {
                try await Task.sleep(nanoseconds: UInt64(NetworkConfig.retryDelay * 1_000_000_000))
                return try await fetchRandomPhoto(retryCount: retryCount + 1)
            } else {
                throw AppError.maxRetryAttemptsReached
            }
        }
    }
    
    private func fetchRandomPhotoInternal() async throws -> UnsplashPhoto {
        let endpoint = UnsplashEndpoint.randomPhoto(
            orientation: "landscape",
            query: "slavic landscape nature",
            contentFilter: "high"
        )
        
        return try await performRequest(endpoint: endpoint)
    }
    
    func downloadImage(from url: URL, retryCount: Int = 0) async throws -> Data {
        do {
            return try await downloadImageInternal(from: url)
        } catch {
            if retryCount < NetworkConfig.maxRetryAttempts {
                try await Task.sleep(nanoseconds: UInt64(NetworkConfig.retryDelay * 1_000_000_000))
                return try await downloadImage(from: url, retryCount: retryCount + 1)
            } else {
                throw AppError.maxRetryAttemptsReached
            }
        }
    }
    
    private func downloadImageInternal(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AppError.imageDownloadFailed
        }
        
        return data
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