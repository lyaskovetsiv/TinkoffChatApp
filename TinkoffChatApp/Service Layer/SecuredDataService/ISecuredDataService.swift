//
//  ISecuredDataService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 17.04.2023.
//

import Foundation

/// Протокол сервиса, отвечающего за работу с чувствительными данными
protocol ISecuredDataService {
	func createNewUserID()
	func getStoredUserID() -> String?
}
