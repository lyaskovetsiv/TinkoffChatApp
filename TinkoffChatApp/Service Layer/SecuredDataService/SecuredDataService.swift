//
//  SecuredDataService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 17.04.2023.
//

import Foundation

/// Класс сервиса, отвечающего за работу с чувствительными данными
final class SecuredDataService: ISecuredDataService {
	// MARK: - Private properties

	private var securedDataStorage: IKeyChainService

	// MARK: - Private init

	init(securedDataStorage: IKeyChainService) {
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
