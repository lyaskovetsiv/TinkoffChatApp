//
//  ProfileModuleInput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 24.04.2023.
//

import Foundation

/// Протокол презентера модуля Profile
protocol ProfileModuleInput {
	func imageWasChosen(url: String)
}
