//
//  ThemeStorageService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 17.04.2023.
//

import Foundation

/// Протокол сервиса, отвечающего за хранение темы приложения
protocol IUserDefaultService {
	func getStoredTheme() -> String?
	func saveTheme(_ theme: String)
}
