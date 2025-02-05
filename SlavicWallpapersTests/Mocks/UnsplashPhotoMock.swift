import Foundation
@testable import SlavicWallpapers

extension SlavicWallpapers.UnsplashPhoto {
    static func mock() -> SlavicWallpapers.UnsplashPhoto {
        return SlavicWallpapers.UnsplashPhoto(
            id: "test-id",
            urls: SlavicWallpapers.UnsplashPhotoUrls(
                raw: "https://example.com/raw.jpg",
                full: "https://example.com/full.jpg",
                regular: "https://example.com/regular.jpg",
                small: "https://example.com/small.jpg",
                thumb: "https://example.com/thumb.jpg"
            )
        )
    }
}
