//
//  UserDataModel.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 18.04.2023.
//

import Foundation

/// Модель для хранения пользовательской информации в FileManager
struct UserDataModel: Codable {
	var name: String?
	var bio: String?
	var image: Data?
}
