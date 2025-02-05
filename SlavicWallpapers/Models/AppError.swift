import Foundation

enum AppError: LocalizedError {
    case networkUnavailable
    case imageDownloadFailed
    case invalidImageData
    case cacheSaveFailed
    case wallpaperSetFailed
    case maxRetryAttemptsReached
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return Localizable.Error.networkUnavailable
        case .imageDownloadFailed:
            return Localizable.Error.imageDownloadFailed
        case .invalidImageData:
            return Localizable.Error.invalidImageData
        case .cacheSaveFailed:
            return Localizable.Error.cacheSaveFailed
        case .wallpaperSetFailed:
            return Localizable.Error.wallpaperSetFailed
        case .maxRetryAttemptsReached:
            return Localizable.Error.maxRetryAttemptsReached
        case .fileNotFound:
            return Localizable.Error.fileNotFound
        }
    }
}
