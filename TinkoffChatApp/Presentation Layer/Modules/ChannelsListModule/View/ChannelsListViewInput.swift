//
//  ChannelsListViewInput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Протокол для вью ChannelsList модуля
protocol ChannelsListViewInput: AnyObject {
	func updateData()
	func showChannelAlert(message: String)
	func hideActivityIndicator()
	func showNoDataCase()
}
