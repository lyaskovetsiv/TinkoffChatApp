//
//  UserDefaultsService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Класс сервиса, отвечающиего за работу с данными через  UserDefaults
final class UserDefaultsService: IUserDefaultService {
	// MARK: - Private constants

	private enum Constants {
		static let themekey = "theme"
	}

	// MARK: - Public methods

	/// Метод, отвечающий за получение сохранённой темы из хранилища
	/// - Returns: Тема из хранилища
	public func getStoredTheme() -> String? {
		UserDefaults.standard.string(forKey: Constants.themekey)
	}

	/// Метод, отвечающий за сохранение темы в хранилище
	/// - Parameter theme: Тема для сохранения
	public func saveTheme(_ theme: String) {
		UserDefaults.standard.set(theme, forKey: Constants.themekey)
	}
}
