import Foundation

protocol APIClientProtocol {
    func fetchRandomPhoto() async throws -> WallpaperResponse
    func downloadImage(from urlPath: String) async throws -> Data
}
