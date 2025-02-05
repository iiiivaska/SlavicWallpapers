import XCTest
@testable import SlavicWallpapers

final class APIClientTests: XCTestCase {
    var sut: APIClient!
    var mockSession: MockURLSession!

    override func setUp() async throws {
        try await super.setUp()
        mockSession = MockURLSession()
        sut = await APIClient.createForTesting(session: mockSession)
    }

    override func tearDown() async throws {
        sut = nil
        mockSession = nil
        try await super.tearDown()
    }

    func testFetchRandomPhoto_Success() async throws {
        // Given
        let expectedPhoto = UnsplashPhoto.mock() as SlavicWallpapers.UnsplashPhoto
        let jsonData = try JSONEncoder().encode(expectedPhoto)
        let response = HTTPURLResponse(statusCode: 200).require()
        mockSession.mockResponse = (jsonData, response)

        // When
        let photo = try await sut.fetchRandomPhoto()

        // Then
        XCTAssertEqual(photo.id, expectedPhoto.id)
        XCTAssertEqual(photo.urls.regular, expectedPhoto.urls.regular)
    }

    func testFetchRandomPhoto_NetworkError() async throws {
        // Given
        mockSession.mockError = AppError.networkUnavailable

        // When/Then
        do {
            _ = try await sut.fetchRandomPhoto()
            XCTFail("Expected max retries error")
        } catch {
            // После всех повторных попыток получаем maxRetryAttemptsReached
            XCTAssertEqual(error as? AppError, .maxRetryAttemptsReached)
            // Проверяем, что было сделано правильное количество попыток
            XCTAssertEqual(mockSession.requestCount, NetworkConfig.maxRetryAttempts + 1)
        }
    }

    func testDownloadImage_Success() async throws {
        // Given
        let imageData = makeTestData("fake-image-data")
        let response = makeTestResponse(statusCode: 200)
        mockSession.mockResponse = (imageData, response)
        let url = makeTestURL()

        // When
        let downloadedData = try await sut.downloadImage(from: url)

        // Then
        XCTAssertEqual(downloadedData, imageData)
    }

    func testDownloadImage_Retry() async throws {
        // Given
        let imageData = makeTestData("success-data")
        let response = makeTestResponse(statusCode: 200)
        mockSession.mockResponses = [
            MockResponse(data: nil, response: nil, error: AppError.networkUnavailable),
            MockResponse(data: imageData, response: response, error: nil)
        ]
        let url = makeTestURL()

        // When
        let downloadedData = try await sut.downloadImage(from: url)

        // Then
        XCTAssertEqual(downloadedData, imageData)
        XCTAssertEqual(mockSession.requestCount, 2)
    }

    func testDownloadImage_MaxRetriesExceeded() async throws {
        // Given
        mockSession.mockError = AppError.networkUnavailable
        let url = makeTestURL()

        // When/Then
        do {
            _ = try await sut.downloadImage(from: url)
            XCTFail("Expected max retries error")
        } catch {
            XCTAssertEqual(error as? AppError, .maxRetryAttemptsReached)
            XCTAssertEqual(mockSession.requestCount, NetworkConfig.maxRetryAttempts + 1)
        }
    }
}

// MARK: - Mocks

private extension APIClient {
    static func createForTesting(session: URLSessionProtocol) -> APIClient {
        return APIClient(session: session)
    }
}

// Добавим extension для безопасного force unwrap в тестах
private extension Optional {
    func require(file: StaticString = #file, line: UInt = #line) -> Wrapped {
        guard let value = self else {
            fatalError("Required value was nil", file: file, line: line)
        }
        return value
    }
}

// Обновим MockURLSession для избежания large tuple
struct MockResponse {
    let data: Data?
    let response: HTTPURLResponse?
    let error: Error?
}

final class MockURLSession: URLSessionProtocol {
    var mockResponse: (Data, HTTPURLResponse)?
    var mockError: Error?
    var mockResponses: [MockResponse] = []
    var requestCount = 0

    func data(from url: URL) async throws -> (Data, URLResponse) {
        requestCount += 1

        if !mockResponses.isEmpty {
            let response = mockResponses.removeFirst()
            if let error = response.error {
                throw error
            }
            if let data = response.data, let urlResponse = response.response {
                return (data, urlResponse)
            }
        }

        if let error = mockError {
            throw error
        }

        if let (data, response) = mockResponse {
            return (data, response)
        }

        throw AppError.networkUnavailable
    }
}

private extension HTTPURLResponse {
    convenience init?(statusCode: Int) {
        let url = URL(string: "https://example.com").require()
        self.init(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
    }
}

// Добавим вспомогательные функции для тестов
private extension APIClientTests {
    func makeTestURL() -> URL {
        URL(string: "https://example.com/image.jpg").require()
    }

    func makeTestData(_ string: String) -> Data {
        Data(string.utf8)
    }

    func makeTestResponse(statusCode: Int) -> HTTPURLResponse {
        let url = URL(string: "https://example.com").require()
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        ).require()
    }
}
