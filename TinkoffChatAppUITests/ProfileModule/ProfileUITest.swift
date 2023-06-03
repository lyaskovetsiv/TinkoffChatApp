//
//  ProfileUITest.swift
//  TinkoffChatAppUITests
//
//  Created by Ivan Lyaskovets on 05.05.2023.
//

import XCTest

/// Класс UI тестов для экрана Profile модуля
final class ProfileUITest: XCTestCase {

	private let app = XCUIApplication()

	func testProfileUI() {
		// Arrange
		app.launch()
		// Act
		let tabBar = app.tabBars["Tab Bar"]
		tabBar.buttons["Profile"].tap()
		// Assert
		XCTAssert(app.buttons["addPhotoBtn"].exists)
		XCTAssert(app.staticTexts["userNameLabel"].exists)
		XCTAssert(app.images["userImageView"].exists)
	}
}
