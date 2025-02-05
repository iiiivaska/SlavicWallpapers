import Foundation
@testable import SlavicWallpapers

extension WallpaperResponse {
    static func mock() -> WallpaperResponse {
        return WallpaperResponse(
            id: "1BE8FB1A-E2DB-41F7-AAB5-E07CE979F0CB",
            format: "jpg",
            status: "completed",
            width: 1024,
            height: 1024,
            generatedAt: "2025-02-05T19:32:57Z",
            imageURL: "/images/test4.jpg",
            fileSize: 1048576
        )
    }
} 