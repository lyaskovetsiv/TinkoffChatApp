//
//  ThemeServiceTests.swift
//  TinkoffChatAppUnitTests
//
//  Created by Ivan Lyaskovets on 07.05.2023.
//

import XCTest
@testable import TinkoffChatApp

/// Класс с тестами для ThemeService сервисного слоя
final class ThemeServiceTests: XCTestCase {

	var sut: IThemeService!
	var userDefaultsServiceMock: UserDefaultServiceMock!

	override func setUpWithError() throws {
		try super.setUpWithError()
		userDefaultsServiceMock = UserDefaultServiceMock()
		sut = ThemeService(themeStorageService: userDefaultsServiceMock)
	}

	override func tearDownWithError() throws {
		userDefaultsServiceMock = nil
		sut = nil
		try super.tearDownWithError()
	}

	/// Метод, который проверяет вызов метода SaveTheme в Core слое
	/// и правильность получения переданных параметров
	func testChangeThemeCalledSaveThemeMethodInCoreLayer() {
		// Arrange
		let pickedTheme: Theme = .dark
		// Act
		sut.changeTheme(pickedTheme)
		// Assert
		XCTAssertTrue(userDefaultsServiceMock.invokedSaveTheme)
		XCTAssertEqual(userDefaultsServiceMock.invokedSaveThemeCount, 1)
		XCTAssertEqual(userDefaultsServiceMock.invokedSaveThemeParameters?.theme, pickedTheme.description)
	}

	/// Метод, который проверяет правильность передачи сохранённой темы из Core слоя в Service слой
	func testSetupInitialWithStoregedTheme() {
		userDefaultsServiceMock.stubbedGetStoredThemeResult = "Dark"
		sut.setupInitialTheme()
		XCTAssertEqual(sut.getCurrentTheme(), Theme.dark)
	}

	/// Метод, который проверяет правильность передачи пустого значения темы из Core слоя
	/// когда тема не хранится в памяти
	func testSetupInitialThemeNoStoredTheme() {
		userDefaultsServiceMock.stubbedGetStoredThemeResult = nil
		sut.setupInitialTheme()
		XCTAssertEqual(sut.getCurrentTheme(), Theme.light)
	}
}
