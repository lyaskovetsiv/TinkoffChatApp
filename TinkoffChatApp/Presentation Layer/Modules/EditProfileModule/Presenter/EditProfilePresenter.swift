//
//  EditProfilePresenter.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 04.03.2023.
//

import Foundation
import Combine

/// Презентер EditProfile модуля
final class EditProfilePresenter: EditProfileViewOutput {
	// MARK: - Private properties

	// MODULE
	private weak var moduleOutput: ProfileModuleOutput? // координатор
	// MVP
	private weak var view: EditProfileViewInput!
	// Services
	private var userInfoService: IUserInfoService!
	private var themeService: IThemeService!
	private var imageService: IImageService!
	// Requests
	private var userDataRequest: Cancellable? // для изменения данных через userInfoService
	private var updateRequest: Cancellable? // для обновления данных с ProfileModule
	// Properties
	private var isInSavingMode: Bool = false

	// MARK: - Inits

	/// Инициализатор презентера модуля EditProfile
	/// - Parameter view: Вью модуля EditProfile
	/// - Parameter coordinator: Координатор типа IProfileCoordinator
	/// - Parameter userInfoService: Сервис, для работы c локальными данными об юзере
	/// - Parameter themeService: Сервис, для работы с темами приложения
	/// - Parameter imageService: Сервис, для работы с картинками из сети
	init(
		view: EditProfileViewInput,
		coordinator: ProfileModuleOutput,
		userInfoService: IUserInfoService,
		themeService: IThemeService,
		imageService: IImageService) {
		self.view = view
		self.moduleOutput = coordinator
		self.userInfoService = userInfoService
		self.themeService = themeService
		self.imageService = imageService
		
		updateRequest = NotificationCenter.default.publisher(for: Notification.Name(rawValue: "userDataChanged"), object: nil)
			.sink { [weak self] _ in
				self?.view.updateUser()
		}
	}

	// MARK: - Public methods

	/// Метод презентера, который вызывается после того как вью загрузилось
	public func viewDidLoad() {
		moduleOutput?.moduleDidLoad(self)
	}

	/// Метод презентера, обрабатывающий закрытие модального окна (свайп)
	public func viewWillDissapear() {
		if isInSavingMode {
			cancelBtnTapped()
		}
	}

	/// Метод презентера, обрабатывающий сохранение данных пользователя
	/// - Parameter model: Модель обновлённого юзера
	public func saveBtnTapped(model: EditedProfileModel) {
		isInSavingMode = true
		view.freezeUIInteraction()
		let user = convertModel(user: model)
		let queue = DispatchQueue.global(qos: .background)
		userDataRequest = userInfoService.saveUserInfo(queue: queue, user: user, image: model.avatar)
			.subscribe(on: queue, options: nil)
			.receive(on: DispatchQueue.main)
			.handleEvents(receiveCancel: { [weak self] in
				self?.userInfoService.cancelSaving()
			})
			.handleEvents(receiveCompletion: { [weak self] completion in
				if case let .failure(error) = completion {
					print(error.localizedDescription)
					self?.view.showFailureAlert()
				}
			})
			.sink(receiveCompletion: { [weak self] _ in
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDataChanged"), object: nil)
				self?.view.showSuccessAlert()
				self?.view.updateUser()
				self?.isInSavingMode = false
			}, receiveValue: { _ in })
	}

	/// Метод презентера, обрабатывающий нажатие кнопки cancel
	public func cancelBtnTapped() {
		if isInSavingMode {
			userDataRequest?.cancel()
			view.updateUser()
			view.unfreezeUIInteraction()
			isInSavingMode = false
		} else {
			closeBtnTapped()
		}
	}

	/// Метод презентера, обрабатывающий закрытие экрана
	public func closeBtnTapped() {
		moduleOutput?.wantToCloseEditModule()
	}

	/// Метод, презентера, обрабатывающий нажатие на пункт "Загрузить" из меню способов выбора аватарки пользователя
	public func networkGalleryTapped() {
		moduleOutput?.wantToOpenNetworkGalleryModule(flow: .edit)
		
	}

	/// Метод презентера, создающий инициалы пользователя
	public func createInitials(name: String) -> String {
		var initials = ""
		let components = name.components(separatedBy: .whitespaces)
		for word in components {
			if let letter = word.first {
				initials += String(letter)
			}
		}
		return initials
	}

	/// Метод, презентера, возвращающий текущую тему
	/// - Returns: Текущая тема
	public func getCurrentTheme() -> Theme {
		themeService.getCurrentTheme()
	}
}

// MARK: - Private methods

extension EditProfilePresenter {
	private func convertModel(user: EditedProfileModel) -> ProfileModel {
		ProfileModel(userName: user.name, userBio: user.bio)
	}
}

extension EditProfilePresenter: ProfileModuleInput {
	/// Метод, который сообщает, что была выбрана аватарка пользователя из галлереи
	/// - Parameter url: url аватарки
	public func imageWasChosen(url: String) {
		imageService.loadImage(from: url) { [weak self] result in
			switch result {
			case .success(let model):
				DispatchQueue.main.async {
					self?.view.updateImageView(model: model)
				}
			case .failure(let error):
				print(error)
			}
		}
	}
}
