//
//  NetworkGalleryInput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 21.04.2023.
//

import Foundation

/// Протокол для вью NetworkGallery модуля
protocol NetworkGalleryViewInput: AnyObject {
	func hideActivityIndicator()
	func reloadView()
}
