//
//  ChannelsListPresenter.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 04.03.2023.
//

import Foundation
import UIKit
import Combine

/// Презентер ChannelsList модуля 
final class ChannelsListPresenter: IChannelsListPresenter {
	// MARK: - Private properties
	
	private enum LoadingCoreDataResult {
		case data([ChannelModel])
		case empty
		case error
	}
	
	private enum ChannelsServerErrors {
		case emptyChannelName
		case canNotLoadChannels
		case canNotDeleteChannel
		
		var description: String {
			switch self {
			case .emptyChannelName:
				return "Название канала не может быть пустым"
			case .canNotLoadChannels:
				return "Загрузка каналов c cервера прервана по техническим причинам"
			case .canNotDeleteChannel:
				return "Удаление канала на сервере прервано по техническим причинам"
			}
		}
	}
	
	private weak var view: IChannelsListView!
	private var moduleCoordinator: IChannelCoordinator!
	private var dataManager: DataManager?
	private var coreDataManager: ICoreDataProtocol!
	
	private var channels: [ChannelModel] = []
	private var dataRequest: Cancellable?

	private var isFirstLoad: Bool = true

	// MARK: - Inits

	/// Инициализатор презетера ConversationsList модуля
	/// - Parameter view: Вью ConversationsList модуля
	/// - Parameter coordinator: Координатор типа IChannelCoordinator
	init(view: IChannelsListView, coordinator: IChannelCoordinator) {
		self.view = view
		self.moduleCoordinator = coordinator
		self.dataManager = DataManager.shared
		self.coreDataManager = CoreDataManager.shared
		loadChannels()
	}

	// MARK: - Public methods

	/// Метод, возвращающий количество диалогов в секции по индексу
	/// - Parameter section: Индекс секции
	/// - Returns: Число диалогов в секции
	public func getNumberOfChannels() -> Int {
		channels.count
	}

	/// Метод, возвращающий  канал для строки
	/// - Parameters:
	///   - row: Индекс строки
	/// - Returns: Модель диалога типа ChannelModel
	public func getChannel(row: Int) -> ChannelModel {
		let channel = channels[row]
		var editedChannel = channel
		if let lastMessage = editedChannel.lastMessage {
			let editedLastMessage = lastMessage.trimmingCharacters(in: .whitespacesAndNewlines)
			if editedLastMessage == "" {
				editedChannel.lastMessage = nil
			} else {
				editedChannel.lastMessage = editedLastMessage
			}
		}
		let editedTitle = editedChannel.name.trimmingCharacters(in: .whitespacesAndNewlines)
		if editedTitle == "" {
			editedChannel.name = "Канал без названия"
		} else {
			editedChannel.name = editedTitle
		}
		return editedChannel
	}
	
	/// Метод, обрабатывающий нажатие конкретной ячейки с каналом
	/// - Parameters:
	///   - row: Индекс строки
	public func cellDidTapped(row: Int) {
		let channel = getChannel(row: row)
		moduleCoordinator.showChannel(model: channel)
	}

	/// Метод, обрабатывающий нажатие кнопки AddChannel
	/// - Parameter title: Название нового канала
	public func createBtnTapped(with title: String) {
		if title.trimmingCharacters(in: .whitespaces) == "" {
			view.showChannelAlert(message: ChannelsServerErrors.emptyChannelName.description)
		} else {
			print("Добавляем новый канал на сервер")
			dataRequest = dataManager?.createChannel(title: title)
				.subscribe(on: DispatchQueue.global(qos: .userInitiated))
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { [weak self] completion in
					if case let .failure(error) = completion {
						print(error.localizedDescription)
						self?.view.showChannelAlert(message: ChannelsServerErrors.emptyChannelName.description)
					}
				}, receiveValue: { [weak self] _ in
					print("Успешно добавили новый канал на сервер")
					self?.loadChannelsFromServer()
				})
		}
	}

	/// Метод, обрабатывающий pullToRefresh
	public func refreshChannels() {
		loadChannelsFromServer()
	}

	/// Метод, обрабатывающий нажатие на кнопку delete  при свайпе ячейки (удаление чата)
	/// - Parameter indexPath: Индекс ячейки
	public func deleteChannelTapped(at indexPath: IndexPath) {
		let channel = channels[indexPath.row]
		// Удаляем канал на сервере
		dataRequest = dataManager?.deleteChannel(channelId: channel.id)
			.subscribe(on: DispatchQueue.global(qos: .userInitiated))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
				guard let self = self else {return}
				switch completion {
				case .finished:
					print("Канал бы успешно удалён на сервере")
					self.deleteChannelOnCoreData(channel: channel) { result in
						switch result {
						case .success:
							let result = self.loadChannelsFromCoreData()
							switch result {
							case .data(let savedChannels):
								self.channels = savedChannels
								DispatchQueue.main.async {
									self.view.updateData()
								}
							case .empty, .error:
								DispatchQueue.main.async {
									self.view.showNoDataCase()
								}
							}
						case .failure(let error):
							print(error.localizedDescription)
						}
					}
				case .failure(let error):
					print("Ошибка при удалении канала на сервере")
					print(error.localizedDescription)
					self.view.showChannelAlert(message: ChannelsServerErrors.canNotDeleteChannel.description)
				}
			}, receiveValue: { _ in
			})
	}
}

// MARK: - Private methods

extension ChannelsListPresenter {
	private func loadChannels() {
		let result = loadChannelsFromCoreData()
		switch result {
		// Если есть данные, отображаем их, загружаем новые данные с сервера
		case .data(let savedChannels):
			channels = savedChannels
			view.updateData()
			loadChannelsFromServer()
		// Если данных нет, или случилась ошибка загрузки, показываем в консоле ошибку, показываем заглушку и грузим данные из сети
		case .empty, .error:
			view.showNoDataCase()
			loadChannelsFromServer()
			print("Загрузили каналы из сети")
		}
	}

	private func loadChannelsFromServer() {
		print("Загружаем каналы из сети")
		dataRequest = dataManager?.loadChannels()
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
				if case let .failure(error) = completion {
					print(error.localizedDescription)
					self?.view.showChannelAlert(message: ChannelsServerErrors.canNotLoadChannels.description)
				}
			}, receiveValue: { [weak self] result in
				guard let self = self else { return }
				if self.isFirstLoad {
					self.view.hideActivityIndicator()
				}
				self.isFirstLoad = false
				// Сортируем полученные данные по дате
				self.channels = result
				self.channels.sort {
					if let date1 = $0.lastActivity, let date2 = $1.lastActivity {
							return date1 > date2
					}
					return $0.lastActivity != nil && $1.lastActivity == nil
				}
				self.view.updateData()
				print("Загрузка каналов из сети успешно завершена. Количество каналов: \(result.count)")
				CoreDataLogger.shared.log(state: .checkingChannelsInLocalStore)
				for channel in self.channels {
					self.saveChannelonCoreData(channel: channel)
				}
				CoreDataLogger.shared.log(state: .finishedCheckingChannelsInLocalStore)
				self.clearFromTrash()
			})
	}

	private func loadChannelsFromCoreData() -> LoadingCoreDataResult {
		do {
			CoreDataLogger.shared.log(state: .loadingChannels)
			let dbChannels = try coreDataManager.fetchChannels()
			let channels: [ChannelModel] = dbChannels.compactMap { dbChannel in
				guard let id = dbChannel.id, let name = dbChannel.name else { return nil }
				return ChannelModel(id: id, name: name, image: nil, lastMessage: dbChannel.lastMessage ?? nil, lastActivity: dbChannel.lastActivity ?? nil)
			}
			CoreDataLogger.shared.log(state: .channelsLoaded(count: channels.count))
			if channels.isEmpty {
				return .empty
			}
			return .data(channels)
		} catch {
			CoreDataLogger.shared.log(error: .canNotFetchChannels)
			print(error.localizedDescription)
			return .error
		}
	}

	private func saveChannelonCoreData(channel: ChannelModel) {
		coreDataManager.saveChannel { context in
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
				CoreDataLogger.shared.log(state: .channelSaved(id: channel.id))
			}
		}
	}

	private func clearFromTrash () {
		coreDataManager.deleteChannel { [weak self] context in
			guard let self = self else {return}
			let fetchRequest = DBChannel.fetchRequest()
			let dbChannels = try context.fetch(fetchRequest)
			for dbChannel in dbChannels {
				if !self.channels.contains(where: { $0.id == dbChannel.id }) {
					context.delete(dbChannel)
					CoreDataLogger.shared.log(state: .trashChannelFound(id: dbChannel.id ?? ""))
				} else {
					continue
				}
			}
		} completion: { result in
			switch result {
			case .success:
				CoreDataLogger.shared.log(state: .chekingTrashChannelsInLocalStore)
				return
			case .failure(let error):
				CoreDataLogger.shared.log(error: .canNotDeleteChannel)
				print(error.localizedDescription)
			}
		}
	}

	private func deleteChannelOnCoreData(channel: ChannelModel, completion: @escaping (Result<Void, Error>) -> Void) {
		CoreDataLogger.shared.log(state: .deletingChannel)
		coreDataManager.deleteChannel(block: { context in
			let fetchRequest = DBChannel.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "id == %@", channel.id as CVarArg)
			guard let dbChannel = try context.fetch(fetchRequest).first else {
				completion(.failure(CoreDataError.canNotFetchChannel))
				return
			}
			context.delete(dbChannel)
		}, completion: { result in
			switch result {
			case .success:
				CoreDataLogger.shared.log(state: .channelWasDeleted)
				completion(.success(()))
			case .failure(let error):
				CoreDataLogger.shared.log(error: .canNotDeleteChannel)
				completion(.failure(error))
			}
		})
	}
}
