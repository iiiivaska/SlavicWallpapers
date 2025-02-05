enum AccessibilityIdentifiers {
    static let updateWallpaperButton = "updateWallpaperButton"
    static let openFolderButton = "openFolderButton"
    static let backgroundUpdateButton = "backgroundUpdateButton"
    static let updateIntervalButton = "updateIntervalButton"
    static let wallpaperModeButton = "wallpaperModeButton"
    static let quitButton = "quitButton"
    
    static func wallpaperModeOption(_ mode: WallpaperMode) -> String {
        "wallpaperMode.\(mode.rawValue)"
    }
} 