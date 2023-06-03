//
//  UserDefaultServiceMock.swift
//  TinkoffChatAppUnitTests
//
//  Created by Ivan Lyaskovets on 07.05.2023.
//

import XCTest
@testable import TinkoffChatApp

/// Моковый класс для работы с кор сервисом типа UserDefaults
final class UserDefaultServiceMock: IUserDefaultService {

	var invokedGetStoredTheme = false
	var invokedGetStoredThemeCount = 0
	var stubbedGetStoredThemeResult: String!

	func getStoredTheme() -> String? {
		invokedGetStoredTheme = true
		invokedGetStoredThemeCount += 1
		return stubbedGetStoredThemeResult
	}

	var invokedSaveTheme = false
	var invokedSaveThemeCount = 0
	var invokedSaveThemeParameters: (theme: String, Void)?
	var invokedSaveThemeParametersList = [(theme: String, Void)]()

	func saveTheme(_ theme: String) {
		invokedSaveTheme = true
		invokedSaveThemeCount += 1
		invokedSaveThemeParameters = (theme, ())
		invokedSaveThemeParametersList.append((theme, ()))
	}
}
