import Foundation

protocol APIClientProtocol {
    func fetchRandomPhoto(retryCount: Int) async throws -> UnsplashPhoto
    func downloadImage(from url: URL, retryCount: Int) async throws -> Data
} 