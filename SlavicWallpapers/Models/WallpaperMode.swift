import Foundation

enum WallpaperMode: String, CaseIterable {
    case same        // Одинаковые обои на всех мониторах
    case different   // Разные обои на каждом мониторе

    var localizedName: String {
        switch self {
        case .same:
            return NSLocalizedString("wallpaper.mode.same", comment: "Same wallpaper on all monitors")
        case .different:
            return NSLocalizedString("wallpaper.mode.different", comment: "Different wallpaper on each monitor")
        }
    }
}
