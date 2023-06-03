//
//  ChannelViewOutput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Протокол для презентера Channel модуля
protocol ChannelViewOutput {
	func getNumberOfSections() -> Int
	func getTitleForSection(index: Int) -> String
	func getNumberOfRows(in section: Int) -> Int
	func getMessage(indexPath: IndexPath) -> (message: MessageModel, hasImage: Bool, isRepeated: Bool, isLast: Bool)
	func sendMessage(text: String?)
	func getUserID() -> String?
	func photoImageTapped()
	func getImage(url: String, completion: @escaping (ImageModel?) -> Void)
	func viewWillAppear()
	func viewDidDissapear()
}
