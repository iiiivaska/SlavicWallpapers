import Foundation

enum APIConfig {
    // Замените на ваш реальный API ключ от Unsplash
    static let unsplashAccessKey = "BJlndG2iUzwlUR1ohEVX65Mx1W0wy0Oaw-H_StiqRuk"
    static let baseURL = "https://api.unsplash.com"
    static let photosEndpoint = "/photos/random"
}

struct UnsplashPhoto: Codable {
    let id: String
    let urls: PhotoURLs
    let user: User
    
    struct PhotoURLs: Codable {
        let raw: String
        let full: String
        let regular: String
    }
    
    struct User: Codable {
        let name: String
    }
} 