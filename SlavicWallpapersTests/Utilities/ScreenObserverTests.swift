import XCTest
@testable import SlavicWallpapers

final class ScreenObserverTests: XCTestCase {
    var sut: ScreenObserver!

    override func setUp() {
        super.setUp()
        sut = ScreenObserver.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitialScreenCount() {
        // Given
        let expectedCount = NSScreen.screens.count

        // Then
        XCTAssertEqual(sut.screensCount, expectedCount)
    }

    func testScreenCountUpdate() {
        // Given
        let initialCount = sut.screensCount

        // When
        NotificationCenter.default.post(
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        // Then
        let expectation = XCTestExpectation(description: "Screen count update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.screensCount, NSScreen.screens.count)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
} 