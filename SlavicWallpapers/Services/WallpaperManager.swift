import AppKit

enum WallpaperError: Error {
    case invalidScreen
    case unableToSetWallpaper
    case fileNotFound
}

actor WallpaperManager {
    static let shared = WallpaperManager()

    var workspace: NSWorkspace
    var userDefaults: UserDefaults
    private let wallpaperModeKey = "WallpaperMode"

    private init() {
        self.workspace = .shared
        self.userDefaults = .standard
    }

    var wallpaperMode: WallpaperMode {
        get {
            if let savedMode = userDefaults.string(forKey: wallpaperModeKey),
               let mode = WallpaperMode(rawValue: savedMode) {
                return mode
            }
            return .same
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: wallpaperModeKey)
        }
    }

    func setWallpaper(from url: URL) async throws {
        switch wallpaperMode {
        case .same:
            try await setSameWallpaper(from: url)
        case .different:
            try await setDifferentWallpapers()
        }
    }

    private func setSameWallpaper(from url: URL) async throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw AppError.fileNotFound
        }

        for screen in NSScreen.screens {
            try setWallpaper(from: url, for: screen)
        }
    }

    private func setDifferentWallpapers() async throws {
        let imageService = ImageService.shared

        for screen in NSScreen.screens {
            let imageUrl = try await imageService.downloadAndCacheImage()
            try setWallpaper(from: imageUrl, for: screen)
        }
    }

    private func setWallpaper(from url: URL, for screen: NSScreen) throws {
        let options: [NSWorkspace.DesktopImageOptionKey: Any] = [
            .imageScaling: NSImageScaling.scaleProportionallyUpOrDown.rawValue,
            .allowClipping: true
        ]

        try workspace.setDesktopImageURL(url, for: screen, options: options)
    }

    func setMode(_ mode: WallpaperMode) {
        wallpaperMode = mode
    }

    func getCurrentMode() -> WallpaperMode {
        wallpaperMode
    }
}
