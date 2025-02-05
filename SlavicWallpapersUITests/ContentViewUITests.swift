import XCTest
@testable import SlavicWallpapers

final class ContentViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testMenuBarIconExists() throws {
        let menuBarIcon = app.statusItems.firstMatch
        XCTAssertTrue(menuBarIcon.exists, "Menu bar icon should exist")
    }

    func testOpenCloseMenu() throws {
        let menuBarIcon = app.statusItems.firstMatch
        menuBarIcon.click()

        let updateButton = app.buttons[AccessibilityIdentifiers.updateWallpaperButton]
        XCTAssertTrue(updateButton.waitForExistence(timeout: 5),
                      "Update wallpaper button should be visible")

        // Закрываем меню, нажимая Escape
        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])

        // Проверяем, что меню закрылось
        let menuClosed = XCTWaiter.wait(for: [
            XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "exists == false"),
                object: updateButton
            )
        ], timeout: 5.0)

        XCTAssertEqual(menuClosed, .completed, "Menu should be closed")
    }

    func testUpdateIntervalPicker() throws {
        let menuBarIcon = app.statusItems.firstMatch
        menuBarIcon.click()

        // Включаем фоновое обновление если выключено
        let backgroundToggle = app.buttons[AccessibilityIdentifiers.backgroundUpdateButton]
        XCTAssertTrue(backgroundToggle.waitForExistence(timeout: 5),
                      "Background update button should exist")

        if backgroundToggle.value as? String == "off" {
            backgroundToggle.click()
        }

        // Открываем выбор интервала
        let intervalButton = app.buttons[AccessibilityIdentifiers.updateIntervalButton]
        XCTAssertTrue(intervalButton.waitForExistence(timeout: 5),
                      "Update interval button should exist")
        intervalButton.click()

        // Даем время для анимации
        Thread.sleep(forTimeInterval: 1)

        // Проверяем элементы интерфейса, используя более общий поиск
        let hoursSlider = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@", "hoursSlider"))
            .firstMatch
        XCTAssertTrue(hoursSlider.waitForExistence(timeout: 5),
                      "Hours slider should exist")

        let minutesSlider = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@", "minutesSlider"))
            .firstMatch
        XCTAssertTrue(minutesSlider.waitForExistence(timeout: 5),
                      "Minutes slider should exist")

        // Проверяем кнопки
        let okButton = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@", "okButton"))
            .firstMatch
        XCTAssertTrue(okButton.waitForExistence(timeout: 5),
                      "OK button should exist")

        let cancelButton = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@", "cancelButton"))
            .firstMatch
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5),
                      "Cancel button should exist")
    }
}
