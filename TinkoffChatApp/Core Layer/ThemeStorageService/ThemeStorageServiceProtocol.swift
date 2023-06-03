//
//  ThemeStorageService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 14.04.2023.
//

import Foundation

/// Протокол для выбора темы
protocol IThemeStorageService: AnyObject {
	func fetchStoredTheme() -> Theme?
	func saveSelectedTheme(theme: Theme, completion: @escaping (Result<Theme, Error>) -> Void)
}
