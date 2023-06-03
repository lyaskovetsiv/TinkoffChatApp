//
//  RemoteDataService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 02.04.2023.
//

import Foundation
import Combine
import TFSChatTransport

///  Класс сервиса для работы с данными на удалённом сервере
final class RemoteDataService: IRemoteDataService {
	// MARK: - Private constants

	private let chatService = ChatService(host: "167.235.86.234", port: 8080)
	private var sseService: SSEService! = SSEService(host: "167.235.86.234", port: 8080)

	// MARK: - Deinit

	deinit {
		unSubscribeOnEvents()
	}

	// MARK: - Public methods

	/// Метод, который подписывается на изменения на сервере
	/// - Returns: Паблишер типа AnyPublisher<ChattEvent, Error>
	public func subscribeOnEvents() -> AnyPublisher<ChattEvent, Error> {
		sseService.subscribeOnEvents()
			.retry(3)
			.compactMap { event -> ChattEvent? in
				guard let eventType = EventtType(rawValue: event.eventType.rawValue) else {
					return nil
				}
				return ChattEvent(eventType: eventType, resourceID: event.resourceID)
			}
			.eraseToAnyPublisher()
	}

	/// Метод, который позволяет отписаться от событий
	public func unSubscribeOnEvents() {
		sseService.cancelSubscription()
	}

	/// Метод, который переподписывается на SSE
	public func reconnectToService() {
		// Отписались перед удалением ссылки на SSEService
		if sseService != nil {
			unSubscribeOnEvents()
		}
		// Удалили SSEService
		sseService = nil
		// Создали новый SSEService
		sseService = SSEService(host: "167.235.86.234", port: 8080)
	}

	/// Метод, который загружает канал с сервера
	/// - Parameter resourceID: id канала
	/// - Returns: Паблишер типа AnyPublisher<ChannelModel, Error>
	public func loadChannel(resourceID: String) -> AnyPublisher<ChannelModel, Error> {
		chatService.loadChannel(id: resourceID)
			.map({ channel -> ChannelModel in
				var image: UIImage?
				if let urlString = channel.logoURL {
					if let url = URL(string: urlString) {
						do {
							let data = try Data(contentsOf: url)
							image = UIImage(data: data)
						} catch {
							print(error.localizedDescription)
						}
					}
				}
				return ChannelModel(id: channel.id,
									name: channel.name,
									image: image,
									lastMessage: channel.lastMessage,
									lastActivity: channel.lastActivity)
			})
			.eraseToAnyPublisher()
	}

	/// Метод, который загружает каналы
	/// - Returns: Паблишер типа AnyPublisher<[ChannelModel], Error>
	public func loadChannels() -> AnyPublisher<[ChannelModel], Error> {
		chatService.loadChannels()
			.map { channels in
				channels.map { channel in
					var image: UIImage?
					if let urlString = channel.logoURL {
						if let url = URL(string: urlString) {
							do {
								let data = try Data(contentsOf: url)
								image = UIImage(data: data)
							} catch {
								print(error.localizedDescription)
							}
						}
					}
					return ChannelModel(id: channel.id,
								 name: channel.name,
								 image: image,
								 lastMessage: channel.lastMessage,
								 lastActivity: channel.lastActivity)
				}
			}
			.eraseToAnyPublisher()
	}

	/// Метод, который загружает сообщения канала
	/// - Parameter channelId: Идентификатор канала
	/// - Returns: Паблишер типа AnyPublisher<[MessageModel], Error>
	public func loadMessages(channelId: String) -> AnyPublisher<[MessageModel], Error> {
		chatService.loadMessages(channelId: channelId)
			.map { messages in
				messages.map { message in
					MessageModel(id: message.id,
								 userID: message.userID,
								 userName: message.userName,
								 text: message.text,
								 date: message.date)
				}
			}
			.eraseToAnyPublisher()
	}

	/// Метод, который создаёт новый канал
	/// - Parameter title: Название канала
	/// - Returns: Паблишер типа AnyPublisher<Void, Error>
	public func createChannel(title: String) -> AnyPublisher<Void, Error> {
		chatService.createChannel(name: title)
			.map { _ in () }
			.eraseToAnyPublisher()
	}

	/// Метод, который отправляет сообщение в канале
	/// - Parameters:
	///   - text: Текст сообщения
	///   - channelId: Идентификатор канала
	///   - userId: Идентификатор пользователя
	///   - userName: Имя пользователя
	/// - Returns: Паблишер типа AnyPublisher<Void, Error>
	public func sendMessage(text: String, channelId: String, userId: String, userName: String) -> AnyPublisher<Void, Error> {
		chatService.sendMessage(text: text, channelId: channelId, userId: userId, userName: userName)
			.map { _ in () }
			.eraseToAnyPublisher()
	}

	/// Метод, который удаляет канал на сервере
	/// - Parameter channelId: id канала
	/// - Returns: Паблишер типа AnyPublisher<Void, Error>
	public func deleteChannel(channelId: String) -> AnyPublisher<Void, Error> {
		chatService.deleteChannel(id: channelId)
			.eraseToAnyPublisher()
	}
}
