import Foundation

enum UnsplashEndpoint {
    case randomPhoto(orientation: String, query: String, contentFilter: String)

    var url: URL? {
        var components = URLComponents(string: APIConfig.baseURL + APIConfig.photosEndpoint)

        switch self {
        case .randomPhoto(let orientation, let query, let contentFilter):
            components?.queryItems = [
                URLQueryItem(name: "orientation", value: orientation),
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "content_filter", value: contentFilter)
            ]
        }

        return components?.url
    }
}
