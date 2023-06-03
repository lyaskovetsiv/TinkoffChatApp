//
//  ChannelsListViewOutput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Протокол для презентера ChannelsList модуля
protocol ChannelsListViewOutput {
	func getNumberOfChannels() -> Int
	func getChannel(row: Int) -> ChannelModel
	func cellDidTapped(row: Int)
	func createBtnTapped(with title: String)
	func refreshChannels()
	func deleteChannelTapped(at indexPath: IndexPath)
	func viewDidLoad()
	func viewWillAppear()
	func viewDidDissapear()
}
