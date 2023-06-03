//
//  ChannelsListPresenter.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 04.03.2023.
//

import Foundation
import Combine

/// Презентер ChannelsList модуля 
final class ChannelsListPresenter: ChannelsListViewOutput {

	// MARK: - Private properties

	// MVP
	private weak var view: ChannelsListViewInput!
	private weak var moduleOutput: ChannelModuleOutput?
	// Sevices
	private var remoteDataService: IRemoteDataService!
	private var localDataService: ILocalDataService!
	private var themesService: IThemeService!
	// Properties
	private var channels: [ChannelModel] = []
	private var cancellables = Set<AnyCancellable>()
	private var sseListener: Cancellable?
	private var isFirstLoad = true

	// MARK: - Inits

	/// Инициализатор презетера ConversationsList модуля
	/// - Parameter view: Вью ConversationsList модуля
	/// - Parameter coordinator: Координатор типа IChannelCoordinator
	/// - Parameter remoteDataService: Сервис для работы с данными на сервере
	/// - Parameter localDataService: Сервис для работы с данными на локальном хранилище
	init(view: ChannelsListViewInput, coordinator: ChannelModuleOutput, remoteDataService: IRemoteDataService, localDataService: ILocalDataService) {
		self.view = view
		self.moduleOutput = coordinator
		self.remoteDataService = remoteDataService
		self.localDataService = localDataService
	}

	// MARK: - Public methods

	// Flow
	/// Метод, презентера, который срабатывает, когда вью впервые загрузилось
	public func viewDidLoad() {
		loadChannels()
	}

	/// Метод презентера, который срабатывает всякий раз, когда вью должна появиться
	public func viewWillAppear() {
		if !isFirstLoad {
			loadChannelsFromServer()
		}
		isFirstLoad = false
		subscribeOnEvents()
	}
	
	/// Метод презентера, который срабатывает когда вью исчезло
	func viewDidDissapear() {
		sseListener?.cancel()
	}

	/// Метод презентера, обрабатывающий pullToRefresh
	public func refreshChannels() {
		loadChannelsFromServer()
	}

	// Channel
	/// Метод презентера, возвращающий количество диалогов
	/// - Returns: Число диалогов в секции
	public func getNumberOfChannels() -> Int {
		channels.count
	}

	/// Метод презентера, обрабатывающий нажатие на конкретную ячейку с каналом
	/// - Parameter row: Индекс строки
	public func cellDidTapped(row: Int) {
		let channel = getChannel(row: row)
		moduleOutput?.wantToOpenChannelModule(model: channel)
	}

	/// Метод презентера, обрабатывающий нажатие кнопки AddChannel
	/// - Parameter title: Название нового канала
	public func createBtnTapped(with title: String) {
		if !checkCreatedChannelTitleForEmpty(title: title) {
			print("Добавляем новый канал на сервер")
			remoteDataService?.createChannel(title: title)
				.subscribe(on: DispatchQueue.global(qos: .userInitiated))
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { [weak self] completion in
					if case let .failure(error) = completion {
						print(error.localizedDescription)
						self?.view.showChannelAlert(message: ChannelError.canNotCreateChannel.description)
					}
				}, receiveValue: { [weak self] _ in
					print("Успешно добавили новый канал на сервер")
					self?.loadChannelsFromServer()
				}).store(in: &cancellables)
		}
	}

	/// Метод презентера, возвращающий  канал для строки
	/// - Parameters:
	///   - row: Индекс строки
	/// - Returns: Модель диалога типа ChannelModel
	public func getChannel(row: Int) -> ChannelModel {
		let channel = channels[row]
		return checkChannelTitleAndLastMessage(channel: channel)
	}

	/// Метод презентера, обрабатывающий нажатие на кнопку delete  при свайпе ячейки (удаление чата)
	/// - Parameter indexPath: Индекс ячейки
	public func deleteChannelTapped(at indexPath: IndexPath) {
		let channel = channels[indexPath.row]
		// Удаляем канал на сервере
		remoteDataService?.deleteChannel(channelId: channel.id)
			.subscribe(on: DispatchQueue.global(qos: .userInitiated))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
				guard let self = self else {return}
				switch completion {
				case .finished:
					print("Канал бы успешно удалён на сервере")
					self.deleteChannelFromLocalStorage(channel: channel) { result in
						switch result {
						case .success:
							let result = self.loadChannelsFromLocalStorage()
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
					self.view.showChannelAlert(message: ChannelError.canNotDeleteChannel.description)
				}
			}, receiveValue: { _ in
			}).store(in: &cancellables)
	}
}

// MARK: - Private methods

extension ChannelsListPresenter {
	private func loadChannels() {
		let result = loadChannelsFromLocalStorage()
		switch result {
		case .data(let savedChannels):
			channels = savedChannels
			view.updateData()
			loadChannelsFromServer()
		case .empty, .error:
			view.showNoDataCase()
			loadChannelsFromServer()
			print("Загрузили каналы из сети")
		}
	}

	private func subscribeOnEvents() {
		sseListener = remoteDataService.subscribeOnEvents()
			.subscribe(on: DispatchQueue.global(qos: .userInitiated))
			.retry(3)
			.sink(receiveCompletion: { [weak self] completion in
				if case let .failure(error) = completion {
					print("SSE: Ошибка при подписке на события сервера - \(error.localizedDescription)")
					// Переподсоединились
					self?.remoteDataService.reconnectToService()
					// Актуализировали текущий список каналов
					self?.loadChannelsFromServer()
					// Переподписались
					self?.subscribeOnEvents()
				}
			}, receiveValue: { [weak self] result in
				guard let self = self else {return}
				switch result.eventType {
				case .add:
					// Оставил повторение, чтобы отслеживать логами add это или update
					print("SSE: На сервере добавлен новый чат")
					// Загружаем канал с сервера
					self.loadChannelFromServer(id: result.resourceID)
				case .update:
					print("SSE: Добавлено новое сообщение")
					// Обновляем сообщение в чате
					self.loadChannelFromServer(id: result.resourceID)
				case .delete:
					print("SSE: Чат был удалён")
					// Находим канал
					if let index = self.channels.firstIndex(where: { channel in
						channel.id == result.resourceID
					}) {
						// Удаляем чат локально
						let channel = self.channels[index]
						self.deleteChannelFromLocalStorage(channel: channel) { result in
							switch result {
							case .success:
								return
							case .failure(let error):
								print(error.localizedDescription)
							}
						}
					}
				}
			})
	}

	// Server
	private func loadChannelFromServer(id: String) {
		self.remoteDataService.loadChannel(resourceID: id)
			.subscribe(on: DispatchQueue.global(qos: .background))
			.sink(receiveCompletion: { _ in
			}, receiveValue: { [weak self] channel in
				guard let self = self else {return}
				// Проверяем есть ли у нас такой канал или нет
				if let index = self.channels.firstIndex(where: { $0.id == channel.id }) {
					// Если есть, то обновляем его данные
					self.channels[index].lastMessage = channel.lastMessage
					self.channels[index].lastActivity = channel.lastActivity
				} else {
					// Добавляем загруженный канал в наш локальный список
					self.channels.append(channel)
				}
				// Обновляем вью
				DispatchQueue.main.async {
					self.sortChannels()
					self.view.updateData()
				}
				// Сохраняем канал в coreData
				self.saveChannelOnLocalStorage(channel: channel)
			}).store(in: &self.cancellables)
	}

	private func loadChannelsFromServer() {
		print("Загружаем каналы из сети")
		remoteDataService?.loadChannels()
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
				if case let .failure(error) = completion {
					print(error.localizedDescription)
					self?.view.showChannelAlert(message: ChannelError.canNotLoadChannels.description)
				}
				self?.view.hideActivityIndicator()
			}, receiveValue: { [weak self] result in
				guard let self = self else { return }
				self.channels = result
				self.sortChannels()
				self.view.updateData()
				print("Загрузка каналов из сети успешно завершена. Количество каналов: \(result.count)")
				for channel in self.channels {
					self.saveChannelOnLocalStorage(channel: channel)
				}
				self.clearFromTrash(channels: self.channels)
			}).store(in: &cancellables)
	}

	// Local
	private func loadChannelsFromLocalStorage() -> LoadingLocalChannelsResult {
		localDataService.fetchChannels()
	}

	private func saveChannelOnLocalStorage(channel: ChannelModel) {
		localDataService.saveChannel(channel: channel)
	}

	private func deleteChannelFromLocalStorage(channel: ChannelModel, completion: @escaping (Result<Void, Error>) -> Void) {
		localDataService.deleteChannel(channel: channel) { result in
			switch result {
			case .success(()):
				completion(.success(()))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	private func clearFromTrash (channels: [ChannelModel]) {
		localDataService.clearFromTrash(channels: channels)
	}

	// Sorting&Clearing
	private func sortChannels() {
		channels.sort {
			if let date1 = $0.lastActivity, let date2 = $1.lastActivity {
				return date1 > date2
			}
			return $0.lastActivity != nil && $1.lastActivity == nil
		}
	}

	private func checkCreatedChannelTitleForEmpty(title: String) -> Bool {
		if title.trimmingCharacters(in: .whitespaces) == "" {
			view.showChannelAlert(message: ChannelError.emptyChannelName.description)
			return true
		}
		return false
	}
	
	private func checkChannelTitleAndLastMessage(channel: ChannelModel) -> ChannelModel {
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
}
