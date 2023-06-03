//
//  ChannelPresenter.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 04.03.2023.
//

import Foundation
import UIKit
import Combine

/// Презентер Channel модуля
final class ChannelPresenter: ChannelViewOutput {

	// MARK: - Private properties

	// MODULE
	private weak var moduleOutput: ChannelModuleOutput?
	// MVP
	private weak var view: ChannelViewInput?
	// Sevices
	private var localDataService: ILocalDataService!
	private var remoteDataService: IRemoteDataService!
	private var securedDataService: ISecuredDataService!
	private var imageService: IImageService!
	// Publishers&Requests
	private var loadPublisher: AnyPublisher<(ProfileModel?, UIImage?), Error>
	private var cancellables = Set<AnyCancellable>()
	private var sseListener: Cancellable?
	// Properties
	private var user: ProfileModel?
	private var channel: ChannelModel
	private var sections: [(date: Date, messages: [MessageModel])] = []
	private var messages: [MessageModel] = []

	// MARK: - Inits

	/// Инициализатор презентора Channel модуля
	/// - Parameter view: Вью Channel модуля
	/// - Parameter channel: Модель типа ChannelModel
	/// - Parameter coordinator: Координатор типа IChannelModuleOutput
	/// - Parameter publisher: Паблишер типа AnyPublisher<(ProfileModel?, UIImage?), Error>
	/// - Parameter remoteDataService: Сервис  для работы с данными на сервере
	/// - Parameter localDataService: Сервис для работы с данными на локальном хранилище
	/// - Parameter securedDataService: Сервис для работы с чувствительными данными
	/// - Parameter imageService: Сервис для работы с картинками из сети
	init(
		view: ChannelViewInput,
		channel: ChannelModel,
		coordinator: ChannelModuleOutput,
		publisher: AnyPublisher<(ProfileModel?, UIImage?), Error>,
		remoteDataService: IRemoteDataService,
		localDataService: ILocalDataService,
		securedDataService: ISecuredDataService,
		imageService: IImageService) {
		self.view = view
		self.channel = channel
		self.moduleOutput = coordinator
		self.loadPublisher = publisher
		self.remoteDataService = remoteDataService
		self.localDataService = localDataService
		self.securedDataService = securedDataService
		self.imageService = imageService
		self.view?.createHeaderUserView(name: channel.name, image: channel.image)
		loadUser()
		loadMessages()
		moduleOutput?.moduleDidLoad(self)
	}

	// MARK: - Public methods

	/// Метод презентера, который срабатывает когда вью должно появиться
	func viewWillAppear() {
		subscribeOnEvents()
	}
	
	/// Метод презентера, который срабатывает когда вью исчезло
	func viewDidDissapear() {
		sseListener?.cancel()
	}

	// DataSource
	/// Метод презентера, возвращающий число секций
	/// - Returns: Число секций
	public func getNumberOfSections() -> Int {
		sections.count
	}

	/// Метод презентера, возвращающий название для секции по индексу
	/// - Parameter index: индекс секции
	/// - Returns: название секции
	public func getTitleForSection(index: Int) -> String {
		return formatDate(date: sections[index].date)
	}
	
	/// Метод презентера, возвращающий чисто строк в секции по индексу
	/// - Parameter section: индекс секции
	/// - Returns: число строк в секции
	public func getNumberOfRows(in section: Int) -> Int {
		sections[section].messages.count
	}

	// Messages
	
	/// Метод презентера, который отвечает за получение сообщения
	/// - Parameter indexPath: Индекс ячейки
	/// - Returns: Кортеж ответных данных
	public func getMessage(indexPath: IndexPath) -> (message: MessageModel, hasImage: Bool, isRepeated: Bool, isLast: Bool) {
		let currentMessage = sections[indexPath.section].messages[indexPath.row]
		var hasImage = false
		let repeated = checkMessageForRepeat(currentMessage: currentMessage, indexPath: indexPath)
		let isLast = checkMessageForLast(currentMessage: currentMessage, indexPath: indexPath)
		if isImageURL(currentMessage.text) {
			hasImage = true
		}
		return (currentMessage, hasImage, repeated, isLast)
	}

	/// Метод презентера, который отвечает за получение картинки из сети
	/// - Parameters:
	///   - url: Адрес картинки
	///   - completion: Обработчик завершения
	public func getImage(url: String, completion: @escaping (ImageModel?) -> Void) {
		imageService.loadImage(from: url) { result in
			switch result {
			case .success(let model):
				completion(model)
			case .failure(let error):
				print(error.localizedDescription)
				completion(nil)
			}
		}
	}

	/// Метод презентера, который отвечает за отправку сообщения на сервер
	/// - Parameter text: Текст сообщения
	public func sendMessage(text: String?) {
		if !checkOutputMessageTextForEmpty(text: text) {
			guard let userId = securedDataService.getStoredUserID() else {
				print("Ошибка при чтении userId")
				return
			}
			guard let userName = user?.userName else {
				print("Ошибка при чтении userName")
				return
			}

			remoteDataService?.sendMessage(text: text ?? "",
												   channelId: channel.id,
												   userId: userId,
												   userName: userName)
			.subscribe(on: DispatchQueue.global(qos: .userInitiated))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
				if case let .failure(error) = completion {
					print(error.localizedDescription)
					self?.view?.showChannelAlert(message: MessagesErrors.canNotSendMessage.description)
				}
			}, receiveValue: { [weak self] _ in
				self?.loadMessagesFromServer()
			}).store(in: &cancellables)
		}
	}

	// User
	/// Метод презентера, возвращающий id юзера
	/// - Returns: id юзера
	public func getUserID() -> String? {
		securedDataService.getStoredUserID()
	}

	// Flow
	/// Метод презентера, обрабатывающий нажатие на иконку с выбором картинки
	public func photoImageTapped() {
		moduleOutput?.wantToOpenNetworkGalleryModule()
	}
}

// MARK: - Private methods

extension ChannelPresenter {
	// Loading
	private func loadMessages() {
		let result = loadMessagesFromLocalStorage()
		switch result {
		// Если есть данные, отображаем их, загружаем новые данные с сервера
		case .data(let savedMessages):
			messages = savedMessages
			sortedMessagesByDate()
			loadMessagesFromServer()
		case .empty, .error:
			view?.showNoDataCase()
			loadMessagesFromServer()
			print("Загрузили сообщения из сети")
		}
	}

	private func loadUser() {
		loadPublisher
			.sink(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					print(error.localizedDescription)
				}
			}, receiveValue: { [weak self] value in
				self?.user = value.0
			}).store(in: &cancellables)
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
					self?.loadMessagesFromServer()
					// Переподписались
					self?.subscribeOnEvents()
				}
			}, receiveValue: { [weak self] result in
				guard let self = self else {return}
				switch result.eventType {
				case .add:
					print("SSE: На сервере добавлен новый чат")
				case .update:
					print("SSE: Добавлено новое сообщение")
					// Если это произошла в нашем чате, обновляем сообщения
					if result.resourceID == self.channel.id {
						self.loadMessagesFromServer()
					}
				case .delete:
					print("SSE: Чат был удалён")
					// Если это был наш чат, то выходим из чата
					if result.resourceID == self.channel.id {
						DispatchQueue.main.async { [weak self] in
							self?.moduleOutput?.wantToCloseChannelModule()
						}
					}
				}
		})
	}

	// Server
	private func loadMessagesFromServer() {
		remoteDataService?.loadMessages(channelId: channel.id)
			.subscribe(on: DispatchQueue.global(qos: .userInitiated))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
				if case let .failure(error) = completion {
					print(error.localizedDescription)
					self?.view?.showChannelAlert(message: MessagesErrors.canNotLoadMessages.description)
				}
				self?.view?.hideActivityIndicator()
			}, receiveValue: { [weak self] receivedMessages in
				guard let self = self else {return}
				self.messages = receivedMessages
				self.sortedMessagesByDate()
				print("Загрузка сообщений c сервера успешно завершена. Количество сообщений: \(self.messages.count)")
				self.view?.updateDataWithScroll(indexPath: self.checkDataForScroll())
				for message in self.messages {
					self.saveMessageOnLocalStorage(message: message, in: self.channel)
				}
			}).store(in: &cancellables)
	}

	// Local
	private func loadMessagesFromLocalStorage() -> LoadingLocalMessagesResult {
		localDataService.fetchMessages(for: channel)
	}

	private func saveMessageOnLocalStorage(message: MessageModel, in channel: ChannelModel) {
		localDataService.saveMessage(message: message, in: channel)
	}

	// Checking
	private func checkOutputMessageTextForEmpty(text: String?) -> Bool {
		guard let text = text, text.trimmingCharacters(in: .whitespaces) != "" else {
			view?.showChannelAlert(message: MessagesErrors.emptyMessage.description)
			return true
		}
		return false
	}

	private func checkInputMessageTextForEmpty(text: String) -> Bool {
		if text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			print("Получено пустое сообщение с сервера")
			return true
		}
		return false
	}

	private func checkMessageForLast(currentMessage: MessageModel, indexPath: IndexPath) -> Bool {
		let count = sections[indexPath.section].messages.count
		if (indexPath.row + 1) < count {
			let nextMessage = sections[indexPath.section].messages[indexPath.row + 1]
			if nextMessage.userID == currentMessage.userID {
				return false
			}
			return true
		}
		return true
	}

	private func checkMessageForRepeat(currentMessage: MessageModel, indexPath: IndexPath) -> Bool {
		if indexPath.row > 0 {
			let previousMessage = sections[indexPath.section].messages[indexPath.row - 1]
			if currentMessage.userID == previousMessage.userID {
				return true
			}
			return false
		}
		return false
	}

	private func checkDataForScroll() -> IndexPath? {
		if sections.isEmpty {
			return nil
		} else {
			let sectionsCount = sections.count - 1
			let rows = sections[sectionsCount].messages
			let rowsCount = rows.count - 1
			return IndexPath(row: rowsCount, section: sectionsCount)
		}
	}

	// Sorting, grouping & formatting
	private func formatDate(date: Date) -> String {
		let formatter = DateFormatter()
		if date < Calendar.current.startOfDay(for: Date()) {
			formatter.dateFormat = "MMM, dd, yyyy"
		} else {
			formatter.dateFormat = "MMM, dd"
		}
		return formatter.string(from: date)
	}

	private func sortedMessagesByDate() {
		let messagesByDate = groupMessagesByDate()
		sections = messagesByDate.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) }
	}

	private func groupMessagesByDate() -> [Date: [MessageModel]] {
		var messagesByDate: [Date: [MessageModel]] = [:]
		for message in messages {
			let calendar = Calendar.current
			let date = calendar.startOfDay(for: message.date)
			if !checkInputMessageTextForEmpty(text: message.text) {
				var editedMessage = message
				let editedText = editedMessage.text.trimmingCharacters(in: .whitespacesAndNewlines)
				editedMessage.text = editedText
				if messagesByDate[date] == nil {
					messagesByDate[date] = [editedMessage]
				} else {
					messagesByDate[date]?.append(editedMessage)
				}
			}
		}
		return messagesByDate
	}

	private func isImageURL(_ text: String) -> Bool {
		// Если текст содержит пробел - значит это не ссылка
		if text.contains(where: { char in
			char == " "
		}) {
			return false
		}
		// Если пробелов нет - проверяем дальше
		guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
			  let match = detector.firstMatch(in: text,
											  options: [],
											  range: NSRange(location: 0, length: text.utf16.count)),
			  let url = match.url else { return false }
		
		return url.pathComponents.contains(where: { component in
			component.contains("photo")
		}) || url.lastPathComponent.hasSuffix("jpeg") || url.lastPathComponent.hasSuffix("png") || url.lastPathComponent.hasSuffix("jpg")
	}
}

// MARK: - IChannelViewOutput

extension ChannelPresenter: ChannelModuleInput {
	func imageWasChosen(url: String) {
		sendMessage(text: url)
	}
}
