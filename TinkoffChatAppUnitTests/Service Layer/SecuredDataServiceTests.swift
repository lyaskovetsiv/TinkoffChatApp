//
//  SecuredDataServiceTests.swift
//  TinkoffChatAppUnitTests
//
//  Created by Ivan Lyaskovets on 07.05.2023.
//

import XCTest
@testable import TinkoffChatApp

/// Класс с тестами для SecuredDataService сервисного слоя
final class SecuredDataServiceTests: XCTestCase {

	var sut: ISecuredDataService!
	var keyChainServiceMock: KeyChainServiceMock!

	override func setUpWithError() throws {
		try super.setUpWithError()
		keyChainServiceMock = KeyChainServiceMock()
		sut = SecuredDataService(securedDataStorage: keyChainServiceMock)
	}

	override func tearDownWithError() throws {
		keyChainServiceMock = nil
		sut = nil
		try super.tearDownWithError()
	}

	/// Метод, который проверяет вызов метода CreateNewUserID из Core слоя
	func testCreateNewUserIdCalledCreateNewUserIdInCoreLayer() throws {
		// Act
		sut.createNewUserID()
		// Assert
		XCTAssertTrue(keyChainServiceMock.invokedCreateUserID)
		XCTAssertEqual(keyChainServiceMock.invokedCreateUserIDCount, 1)
	}

	/// Метод, который проверяет вызов метода  getStoredUserID  из Core слоя
	/// и правильность получения хранимого в памяти userID
	func testGetStoredUserIdCalledGetUserIdWithStoragedIdInCoreLayer() throws {
		// Arrange
		keyChainServiceMock.stubbedGetUserIDResult = "TestId"
		// Act
		let result = sut.getStoredUserID()
		// Assert
		XCTAssertTrue(keyChainServiceMock.invokedGetUserID)
		XCTAssertEqual(keyChainServiceMock.invokedGetUserIDCount, 1)
		XCTAssertEqual(result, "TestId")
	}

	/// Метод, который проверяет вызов метода getStoredUserID  из Core слое
	/// и правильность получения пустого значения, когда в памяти ничего не хранится
	func testGetStoredUserIdCalledGetUserIDWithNoStoragedIdInCoreLayer() throws {
		// Arrange
		keyChainServiceMock.stubbedGetUserIDResult = nil
		// Act
		let result = sut.getStoredUserID()
		// Assert
		XCTAssertTrue(keyChainServiceMock.invokedGetUserID)
		XCTAssertEqual(keyChainServiceMock.invokedGetUserIDCount, 1)
		XCTAssertEqual(result, nil)
	}
}
