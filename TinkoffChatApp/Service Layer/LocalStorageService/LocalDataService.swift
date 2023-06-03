//
//  LocalStorageService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Класс сервиса для работы с локальным хранением данных
final class LocalDataService: ILocalDataService {
	// MARK: - Private properties

	private var coreDataService: ICoreDataService
	private var logger: ICoreDataLogger
	
	// MARK: - Inits

	init(coreDataService: ICoreDataService, logger: ICoreDataLogger) {
		self.coreDataService = coreDataService
		self.logger = logger
	}

	// MARK: - Public methods

	/// Метод, который извлекает каналы из локального хранилища
	/// - Returns: Результат извлечения каналов
	public func fetchChannels() -> LoadingLocalChannelsResult {
		do {
			logger.log(state: .loadingChannels)
			let dbChannels = try coreDataService.fetchChannels()
			let channels: [ChannelModel] = dbChannels.compactMap { dbChannel in
				guard let id = dbChannel.id, let name = dbChannel.name else { return nil }
				return ChannelModel(id: id, name: name, image: nil, lastMessage: dbChannel.lastMessage ?? nil, lastActivity: dbChannel.lastActivity ?? nil)
			}
			logger.log(state: .channelsLoaded(count: channels.count))
			if channels.isEmpty { return .empty }
			return .data(channels)
		} catch {
			logger.log(error: .canNotFetchChannels)
			print(error.localizedDescription)
			return .error
		}
	}

	/// Метод, который сохраняет канал в локальное хранилище
	/// - Parameter channel: Текущий канал
	public func saveChannel(channel: ChannelModel) {
		coreDataService.saveChannel { [weak self] context in
			// Ищем переданный в метод канал по coreData
			let fetchRequest = DBChannel.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "id == %@", channel.id as CVarArg)
			if let dbChannel = try context.fetch(fetchRequest).first {
				dbChannel.lastActivity = channel.lastActivity
				dbChannel.lastMessage = channel.lastMessage
			} else {
				// Если такого канала нет, то создаём новый
				let newDBChannel = DBChannel(context: context)
				newDBChannel.id = channel.id
				newDBChannel.name = channel.name
				newDBChannel.lastActivity = channel.lastActivity
				newDBChannel.lastMessage = channel.lastMessage
				newDBChannel.messages = NSOrderedSet()
				self?.logger.log(state: .channelSaved(id: channel.id))
			}
		}
	}

	/// Метод, который удаляет канал из локального хранилища
	/// - Parameters:
	///   - channel: Текущий канал
	///   - completion: Обработчик событий
	public func deleteChannel(channel: ChannelModel, completion: @escaping (Result<Void, Error>) -> Void) {
		logger.log(state: .deletingChannel)
		coreDataService.deleteChannel(block: { context in
			let fetchRequest = DBChannel.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "id == %@", channel.id as CVarArg)
			guard let dbChannel = try context.fetch(fetchRequest).first else {
				completion(.failure(CoreDataError.canNotFetchChannel))
				return
			}
			context.delete(dbChannel)
		}, completion: { [weak self] result in
			switch result {
			case .success:
				self?.logger.log(state: .channelWasDeleted)
				completion(.success(()))
			case .failure(let error):
				self?.logger.log(error: .canNotDeleteChannel)
				completion(.failure(error))
			}
		})
	}

	/// Метод, который синхронизирует актуальные чаты между сервером и локальным хранилищем
	/// - Parameter channels: Список чатов, полученный с сервера
	public func clearFromTrash(channels: [ChannelModel]) {
		coreDataService.deleteChannel { [weak self] context in
			let fetchRequest = DBChannel.fetchRequest()
			let dbChannels = try context.fetch(fetchRequest)
			for dbChannel in dbChannels {
				if !channels.contains(where: { $0.id == dbChannel.id }) {
					context.delete(dbChannel)
					self?.logger.log(state: .trashChannelFound(id: dbChannel.id ?? ""))
				} else {
					continue
				}
			}
		} completion: { [weak self] result in
			switch result {
			case .success:
				self?.logger.log(state: .chekingTrashChannelsInLocalStore)
				return
			case .failure(let error):
				self?.logger.log(error: .canNotDeleteChannel)
				print(error.localizedDescription)
			}
		}
	}

	/// Метод, который извлекает сообщения для канала из локального хранилища
	/// - Parameter channel: Текущий канал
	/// - Returns: Результат извлечения сообщений
	public func fetchMessages(for channel: ChannelModel) -> LoadingLocalMessagesResult {
		do {
			logger.log(state: .loadingMessages(id: channel.id))
			let dbMessages = try coreDataService.fetchMessages(for: channel.id)
			let messages: [MessageModel] = dbMessages.compactMap { dbMessage in
				guard let messageId = dbMessage.id,
					  let userId = dbMessage.userId,
					  let userName = dbMessage.userName,
					  let messageText = dbMessage.text,
					  let messageDate = dbMessage.date
				else { return nil }
				return MessageModel(id: messageId, userID: userId, userName: userName, text: messageText, date: messageDate)
			}
			logger.log(state: .messagesLoaded(count: messages.count))
			if messages.isEmpty {
				return .empty
			}
			return .data(messages)
		} catch {
			logger.log(error: .canNotFetchChannel)
			print(error.localizedDescription)
			return .error
		}
	}

	/// Метод, который сохраняет сообщение в локальное хранилище
	/// - Parameters:
	///   - message: Сообщение
	///   - channel: Текущий канал
	public func saveMessage(message: MessageModel, in channel: ChannelModel) {
		coreDataService.saveMessages { [weak self] context in
			let fetchRequest = DBChannel.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "id == %@", channel.id as CVarArg)
			guard let dbChannel = try context.fetch(fetchRequest).first else {
				self?.logger.log(error: .canNotFetchChannel)
				self?.logger.log(error: .cantNotSaveMessages)
				return
			}

			guard let dbMessages = dbChannel.messages?.array as? [DBMessage] else { return }

			if !dbMessages.contains(where: { $0.id == message.id }) {
				let newdbMessage = DBMessage(context: context)
				newdbMessage.id = message.id
				newdbMessage.userId = message.userID
				newdbMessage.userName = message.userName
				newdbMessage.text = message.text
				newdbMessage.date = message.date
				newdbMessage.channel = dbChannel
				dbChannel.addToMessages(newdbMessage)
				self?.logger.log(state: .messageSaved(id: message.id))
			}
		}
	}
}
