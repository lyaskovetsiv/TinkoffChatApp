//
//  SecuredDataService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 17.04.2023.
//

import Foundation

/// Класс сервиса, отвечающего за работу с чувствительными данными
final class SecuredDataService: ISecuredDataService {
	/// Главная точка доступа к классу SecuredDataService
	static let shared = SecuredDataService(securedDataStorage: KeyChainService.shared)

	// MARK: - Private properties

	private var securedDataStorage: ISecuredDataStorageService

	// MARK: - Private init

	private init(securedDataStorage: ISecuredDataStorageService) {
		self.securedDataStorage = securedDataStorage
	}

	// MARK: - Public methods

	/// Метод, создающий id пользователя
	public func createNewUserID() {
		securedDataStorage.createUserID()
	}

	/// Метод, который возвращает хранящийся id пользователя
	/// - Returns: id пользователя
	public func getStoredUserID() -> String? {
		securedDataStorage.getUserID()
	}
}
