//
//  ThemeStorageService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 10.03.2023.
//

import Foundation
import UIKit

/// Класс, отвечающий за сохранение темы приложения в FileManager
final class ThemeStorageService: IThemeStorageService {
	/// Главная точка доступа к классу ThemeStorageService
	static let shared = ThemeStorageService()

	// MARK: - Private properties
	
	private let plistFileName = "theme.plist"

	// MARK: - Inits

	private init () {}

	// MARK: - Public methods

	/// Метод, изменяющий текущую тему в FileManager
	/// - Parameter theme: Новая тема
	public func saveSelectedTheme(theme: Theme, completion: @escaping (Result<Theme, Error>) -> Void) {
		let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(plistFileName)
		let dictionary = ["theme": theme.rawValue]
		DispatchQueue.global(qos: .background).async {
			do {
				let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .binary, options: 0)
				do {
					try data.write(to: url)
					completion(.success(theme))
				} catch {
					print("Error in saving theme")
					completion(.failure(error))
				}
			} catch {
				print("Error in serialiation theme")
				completion(.failure(error))
			}
		}
	}

	/// Метод, извлекающий сохранённую тему из Filemanager
	/// - Returns: Сохранённая тема
	public func fetchStoredTheme() -> Theme? {
		let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(plistFileName)
		if let data = try? Data(contentsOf: url) {
			if let dictionary = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Int] {
				if let savedThemeIndex = dictionary["theme"], let savedTheme = Theme(rawValue: savedThemeIndex) {
					return savedTheme
				}
			}
		}
		return nil
	}
}
