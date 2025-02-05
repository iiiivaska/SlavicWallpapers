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

    private enum CodingKeys: String, CodingKey {
        case id, format, status, width, height
        case generatedAt, imageURL, fileSize
    }
}
