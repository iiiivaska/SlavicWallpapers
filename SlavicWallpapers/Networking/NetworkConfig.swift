import Foundation

struct NetworkConfig {
    static let defaultTimeout: TimeInterval = 30
    static let maxRetryAttempts = 3
    static let retryDelay: TimeInterval = 2.0

    struct Headers {
        static let authorization = "Authorization"
        static let clientId = "Client-ID"
        static let contentType = "Content-Type"
        static let accept = "Accept"
    }

    struct ContentType {
        static let json = "application/json"
        static let image = "image/jpeg"
    }
}
