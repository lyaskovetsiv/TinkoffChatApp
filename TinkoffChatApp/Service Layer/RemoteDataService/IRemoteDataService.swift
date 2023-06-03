//
//  IRemoteDataService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 14.04.2023.
//

import Foundation
import Combine

/// Протокол сервиса для работы с данными на удалённом сервере
protocol IRemoteDataService: AnyObject {
	func createChannel(title: String) -> AnyPublisher<Void, Error>
	func loadChannel(resourceID: String) -> AnyPublisher<ChannelModel, Error>
	func loadChannels() -> AnyPublisher<[ChannelModel], Error>
	func loadMessages(channelId: String) -> AnyPublisher<[MessageModel], Error>
	func sendMessage(text: String, channelId: String, userId: String, userName: String) -> AnyPublisher<Void, Error>
	func deleteChannel(channelId: String) -> AnyPublisher<Void, Error>
	func subscribeOnEvents() -> AnyPublisher<ChattEvent, Error>
	func unSubscribeOnEvents()
	func reconnectToService() 
}
