import XCTest
@testable import SlavicWallpapers

final class BackgroundServiceTests: XCTestCase {
    var sut: BackgroundService!
    var mockUserDefaults: BackgroundServiceMockUserDefaults!
    var mockAppState: MockAppState!

    override func setUp() async throws {
        try await super.setUp()
        mockUserDefaults = BackgroundServiceMockUserDefaults()
        mockAppState = MockAppState()
        sut = await BackgroundService.createForTesting(
            userDefaults: mockUserDefaults,
            appState: mockAppState
        )
    }

    override func tearDown() async throws {
        await sut.stopBackgroundUpdates()
        sut = nil
        mockUserDefaults = nil
        mockAppState = nil
        try await super.tearDown()
    }

    func testUpdateInterval_DefaultValue() async {
        // When
        let interval = await sut.updateInterval

        // Then
        XCTAssertEqual(interval, UpdateInterval(hours: 1, minutes: 0))
    }

    func testUpdateInterval_CustomValue() async throws {
        // Given
        let expectedInterval = UpdateInterval(hours: 2, minutes: 30)

        // When
        await sut.setUpdateInterval(expectedInterval)
        let interval = await sut.updateInterval

        // Then
        XCTAssertEqual(interval, expectedInterval)
    }

    func testShouldUpdateWallpaper_NoLastUpdate() async {
        // Given
        mockUserDefaults.lastUpdateDate = nil

        // When
        let shouldUpdate = await sut.shouldUpdateWallpaper()

        // Then
        XCTAssertTrue(shouldUpdate)
    }

    func testShouldUpdateWallpaper_UpdateNeeded() async throws {
        // Given
        let oldDate = Date().addingTimeInterval(-86400) // 24 hours ago
        mockUserDefaults.lastUpdateDate = oldDate
        await sut.setUpdateInterval(UpdateInterval(hours: 1, minutes: 0))

        // When
        let shouldUpdate = await sut.shouldUpdateWallpaper()

        // Then
        XCTAssertTrue(shouldUpdate)
    }

    func testShouldUpdateWallpaper_UpdateNotNeeded() async throws {
        // Given
        let recentDate = Date().addingTimeInterval(-300) // 5 minutes ago
        mockUserDefaults.lastUpdateDate = recentDate
        await sut.setUpdateInterval(UpdateInterval(hours: 24, minutes: 0))

        // When
        let shouldUpdate = await sut.shouldUpdateWallpaper()

        // Then
        XCTAssertFalse(shouldUpdate)
    }

    func testStartBackgroundUpdates_UpdatesWallpaperIfNeeded() async {
        // Given
        mockUserDefaults.lastUpdateDate = nil // Гарантируем, что обновление нужно

        // When
        await sut.startBackgroundUpdates()

        // Then
        XCTAssertEqual(mockAppState.updateWallpaperCallCount, 1)
    }

    func testStopBackgroundUpdates_StopsTimer() async {
        // Given
        await sut.startBackgroundUpdates()

        // When
        await sut.stopBackgroundUpdates()

        // Then
        let isActive = await sut.isTimerActive
        XCTAssertFalse(isActive)
    }

    func testUpdateLastUpdateTime() async {
        // Given
        let beforeUpdate = Date()

        // When
        await sut.updateLastUpdateTime()

        // Then
        let savedDate = mockUserDefaults.lastUpdateDate
        XCTAssertNotNil(savedDate)
        if let savedDate = savedDate {
            XCTAssertGreaterThanOrEqual(savedDate, beforeUpdate)
        }
    }
}

// MARK: - Mocks

private extension BackgroundService {
    static func createForTesting(
        userDefaults: UserDefaults,
        appState: AppStateProtocol
    ) -> BackgroundService {
        BackgroundService(userDefaults: userDefaults, appState: appState)
    }
}

class BackgroundServiceMockUserDefaults: UserDefaults {
    var storage: [String: Any] = [:]
    var lastUpdateDate: Date? {
        get { storage["LastWallpaperUpdate"] as? Date }
        set { storage["LastWallpaperUpdate"] = newValue }
    }

    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }

    override func object(forKey defaultName: String) -> Any? {
        storage[defaultName]
    }

    override func data(forKey defaultName: String) -> Data? {
        storage[defaultName] as? Data
    }
}

class MockAppState: AppStateProtocol {
    var updateWallpaperCallCount = 0

    func updateWallpaper() async {
        updateWallpaperCallCount += 1
    }
}
