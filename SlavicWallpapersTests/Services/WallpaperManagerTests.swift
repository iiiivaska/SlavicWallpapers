import XCTest
@testable import SlavicWallpapers

class WallpaperManagerTests: XCTestCase {
    var wallpaperManager: WallpaperManager!
    var mockWorkspace: MockNSWorkspace!
    var mockUserDefaults: MockUserDefaults!

    override func setUp() async throws {
        try await super.setUp()
        mockWorkspace = MockNSWorkspace()
        mockUserDefaults = MockUserDefaults()
        wallpaperManager = await WallpaperManager.createForTesting(
            workspace: mockWorkspace,
            userDefaults: mockUserDefaults
        )
    }

    override func tearDown() async throws {
        wallpaperManager = nil
        mockWorkspace = nil
        mockUserDefaults = nil
        try await super.tearDown()
    }

    // MARK: - Mode Tests

    func testDefaultWallpaperMode() async {
        let mode = await wallpaperManager.getCurrentMode()
        XCTAssertEqual(mode, .same, "Default wallpaper mode should be 'same'")
    }

    func testSetAndGetWallpaperMode() async {
        await wallpaperManager.setMode(.different)
        let mode = await wallpaperManager.getCurrentMode()
        XCTAssertEqual(mode, .different, "Wallpaper mode should be updated to 'different'")
    }

    func testModePersistedInUserDefaults() async {
        await wallpaperManager.setMode(.different)
        XCTAssertEqual(
            mockUserDefaults.string(forKey: "WallpaperMode"),
            "different",
            "Mode should be persisted in UserDefaults"
        )
    }

    // MARK: - Wallpaper Setting Tests

    func testSetSameWallpaperForAllScreens() async throws {
        let testUrl = try XCTUnwrap(FileManager.default.temporaryDirectory.appendingPathComponent("test.jpg"))
        try Data().write(to: testUrl)
        defer { try? FileManager.default.removeItem(at: testUrl) }

        await wallpaperManager.setMode(.same)
        try await wallpaperManager.setWallpaper(from: testUrl)

        XCTAssertEqual(mockWorkspace.setWallpaperCallCount, NSScreen.screens.count)
        XCTAssertEqual(mockWorkspace.lastWallpaperUrl, testUrl)
    }

    func testSetDifferentWallpapersForScreens() async throws {
        await wallpaperManager.setMode(.different)
        let testUrl = try XCTUnwrap(FileManager.default.temporaryDirectory.appendingPathComponent("test.jpg"))
        try Data().write(to: testUrl)
        defer { try? FileManager.default.removeItem(at: testUrl) }

        try await wallpaperManager.setWallpaper(from: testUrl)

        XCTAssertEqual(mockWorkspace.setWallpaperCallCount, NSScreen.screens.count)
    }

    func testThrowsErrorForNonexistentFile() async {
        let nonexistentUrl = URL(fileURLWithPath: "/nonexistent/path.jpg")

        await wallpaperManager.setMode(.same)

        do {
            try await wallpaperManager.setWallpaper(from: nonexistentUrl)
            XCTFail("Should throw error for nonexistent file")
        } catch {
            XCTAssertEqual(error as? AppError, .fileNotFound)
        }
    }
}

// MARK: - Mock Objects

class MockNSWorkspace: NSWorkspace {
    var setWallpaperCallCount = 0
    var lastWallpaperUrl: URL?
    var lastScreen: NSScreen?
    var lastOptions: [NSWorkspace.DesktopImageOptionKey: Any]?

    override func setDesktopImageURL(
        _ url: URL,
        for screen: NSScreen,
        options: [NSWorkspace.DesktopImageOptionKey: Any] = [:]
    ) throws {
        setWallpaperCallCount += 1
        lastWallpaperUrl = url
        lastScreen = screen
        lastOptions = options
    }
}

class MockUserDefaults: UserDefaults {
    var storage: [String: Any] = [:]

    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }

    override func string(forKey defaultName: String) -> String? {
        return storage[defaultName] as? String
    }
}

// MARK: - WallpaperManager Extension

extension WallpaperManager {
    static func createForTesting(
        workspace: NSWorkspace,
        userDefaults: UserDefaults
    ) async -> WallpaperManager {
        let manager = await WallpaperManager.shared
        await manager.configureForTesting(workspace: workspace, userDefaults: userDefaults)
        return manager
    }

    func configureForTesting(workspace: NSWorkspace, userDefaults: UserDefaults) {
        self.workspace = workspace
        self.userDefaults = userDefaults
    }
}
