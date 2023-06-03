//
//  SettingsViewInput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Протокол для вью Settings модуля
protocol SettingsViewInput: AnyObject {
	func updateUIWithTheme(index: Int)
}
