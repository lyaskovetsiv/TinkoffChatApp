//
//  ChannelViewInput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation
import UIKit

/// Протокол для вью Channel модуля
protocol ChannelViewInput: AnyObject {
	func createHeaderUserView(name: String, image: UIImage?)
	func updateDataWithScroll(indexPath: IndexPath?)
	func showChannelAlert(message: String)
	func hideActivityIndicator()
	func showNoDataCase()
}
