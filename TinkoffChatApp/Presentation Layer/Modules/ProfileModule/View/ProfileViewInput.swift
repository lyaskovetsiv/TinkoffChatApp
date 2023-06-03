//
//  ProfileViewInput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Протокол для вью Profile модуля
protocol ProfileViewInput: AnyObject {
	func updateUser()
	func getUser() -> ProfileModel
	func updateImageView(model: ImageModel) 
}
