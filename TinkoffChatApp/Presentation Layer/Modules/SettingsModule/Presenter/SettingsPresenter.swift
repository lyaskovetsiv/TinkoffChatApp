//
//  SettingsPresenter.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 09.03.2023.
//

import Foundation

/// Презентер Settings модуля
final class SettingsPresenter: SettingsViewOutput {
	// MARK: - Private properties

	private weak var view: SettingsViewInput!
	private var themeService: IThemeService?

	// MARK: - Inits

	/// Инициализатор презентера Settings модуля
	/// - Parameters:
	///   - view: Вью Settings модуля
	///   - themeService: Сервис, для работы с темами приложения
	init(view: SettingsViewInput, themeService: IThemeService) {
		self.view = view
		self.themeService = themeService
		checkUpTheme()
	}

	// MARK: - Public methods
	
	/// Метод, обрабатывающий нажатие на кнопку выбора темы
	/// - Parameter index: Тэг кнопки темы (0 или 1)
	public func didTapThemeButton(index: Int) {
		guard let theme = Theme(rawValue: index) else {return}
		themeService?.changeTheme(theme)
		view.updateUIWithTheme(index: index)
	}
}

// MARK: - Private methods

extension SettingsPresenter {
	private func checkUpTheme() {
		if let themeIndex = themeService?.getCurrentTheme().rawValue {
			view.updateUIWithTheme(index: themeIndex)
		}
	}
}
