//
//  KeyChainServiceProtocol.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 14.04.2023.
//

import Foundation

/// Протокол  сервиса для работы с чувствительными данными
protocol IKeyChainService {
	func createUserID()
	func getUserID() -> String?
}
