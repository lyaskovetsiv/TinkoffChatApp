//
//  KeyChainService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 03.04.2023.
//

import Foundation
import Security

/// Класс для работы с KeyChain
final class KeyChainService: IKeyChainService {
	// MARK: - Private properties

	private let userApp = "Home.TinkoffChatApp"

	// MARK: - Public methods

	/// Метод, отвечающий за генерацию UserID, и его хранение в KeyChain
	public func createUserID() {
		let userID = UUID()
		let userIDString = userID.uuidString

		guard let data = userIDString.data(using: .utf8) else {
			return
		}

		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: userApp,
			kSecValueData as String: data
		]

		let status = SecItemAdd(query as CFDictionary, nil)
		if status != errSecSuccess {
			print("Failed to save userID with error: \(status)")
		}
	}

	/// Метод, отвечающий за загрузку userID из KeyChain
	/// - Returns: userID
	public func getUserID() -> String? {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: userApp,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]

		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)
		guard status == errSecSuccess,
			let data = result as? Data,
			let userID = String(data: data, encoding: .utf8) else {
				return nil
		}

		return userID
	}
}
