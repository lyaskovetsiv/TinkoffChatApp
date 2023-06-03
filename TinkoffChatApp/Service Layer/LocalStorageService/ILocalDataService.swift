//
//  ILocalDataService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Протокол сервиса для работы с локальным хранилищем данных
protocol ILocalDataService {
	func fetchChannels() -> LoadingLocalChannelsResult
	func saveChannel(channel: ChannelModel)
	func deleteChannel(channel: ChannelModel, completion: @escaping (Result<Void, Error>) -> Void)
	func clearFromTrash(channels: [ChannelModel])
	func fetchMessages(for channel: ChannelModel) -> LoadingLocalMessagesResult
	func saveMessage(message: MessageModel, in channel: ChannelModel)
}
