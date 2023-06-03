//
//  NetworkGalleryModuleOutput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 24.04.2023.
//

import Foundation

/// Протокол аутпута модуля с галлереей
protocol NetworkGalleryModuleOutput: AnyObject {
	func imageWasChosen(url: String)
	func wantToCloseNetworkGalleryModule()
}
