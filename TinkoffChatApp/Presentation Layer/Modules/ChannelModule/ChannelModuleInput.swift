//
//  ChannelModuleInput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 25.04.2023.
//

import Foundation

/// Протокол презентера модуля Channel
protocol ChannelModuleInput {
	func imageWasChosen(url: String)
}
