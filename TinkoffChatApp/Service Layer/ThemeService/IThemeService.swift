//
//  IThemeService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 14.04.2023.
//

import Foundation

/// Протокол для выбора темы
protocol IThemeService: AnyObject {
	func getCurrentTheme() -> Theme
	func changeTheme(_ theme: Theme)
	func setupInitialTheme()
}
