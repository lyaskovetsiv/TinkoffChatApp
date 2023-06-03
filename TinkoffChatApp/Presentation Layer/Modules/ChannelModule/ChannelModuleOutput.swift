//
//  ChannelCoordinatorProtocol.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 18.04.2023.
//

import Foundation

/// Протокол координатора для модуля с каналом
protocol ChannelModuleOutput: AnyObject {
	func moduleDidLoad(_ input: ChannelModuleInput)
	func wantToOpenChannelModule(model: ChannelModel)
	func wantToOpenNetworkGalleryModule()
	func wantToCloseChannelModule()
}
