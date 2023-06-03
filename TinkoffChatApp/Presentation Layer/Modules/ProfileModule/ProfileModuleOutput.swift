//
//  ProfileCoordinatorProtocol.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 18.04.2023.
//

import Foundation

/// Протокол координатора для модуля с профайлом
protocol ProfileModuleOutput: AnyObject {
	func moduleDidLoad(_ input: ProfileModuleInput)
	func wantToOpenEditModule()
	func wantToCloseEditModule()
	func wantToOpenNetworkGalleryModule(flow: ProfileNetworkGalleryFlow)
	func wantToCloseNetworkGalleryModule()
}
