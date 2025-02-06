import Foundation

struct WallpaperResponse: Codable {
    let id: String
    let format: String
    let status: String
    let width: Int
    let height: Int
    let generatedAt: String
    let imageURL: String
    let fileSize: Int
}
