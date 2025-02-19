//
//  SlavicWallpapersUITestsLaunchTests.swift
//  SlavicWallpapersUITests
//
//  Created by Василий Буланов on 04.02.2025.
//

import XCTest

final class SlavicWallpapersUITestsLaunchTests: XCTestCase {

    static let allTests = [
        ("testLaunch", testLaunch)
    ]

    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() async throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
