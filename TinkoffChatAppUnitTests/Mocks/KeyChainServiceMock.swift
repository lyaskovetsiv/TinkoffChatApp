//
//  KeyChainServiceMock.swift
//  TinkoffChatAppUnitTests
//
//  Created by Ivan Lyaskovets on 07.05.2023.
//

import XCTest
@testable import TinkoffChatApp

/// Моковый класс для работы с кор сервисом типа Keychain
final class KeyChainServiceMock: IKeyChainService {

	var invokedCreateUserID = false
	var invokedCreateUserIDCount = 0

	func createUserID() {
		invokedCreateUserID = true
		invokedCreateUserIDCount += 1
	}

	var invokedGetUserID = false
	var invokedGetUserIDCount = 0
	var stubbedGetUserIDResult: String!

	func getUserID() -> String? {
		invokedGetUserID = true
		invokedGetUserIDCount += 1
		return stubbedGetUserIDResult
	}
}
