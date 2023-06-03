//
//  ProfilePresenter.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 03.04.2023.
//

import Foundation
import Combine

/// Презентер Profile модуля
final class ProfilePresenter: ProfileViewOutput {
	// MARK: - Private properties

	// MODULE
	private weak var moduleOutput: ProfileModuleOutput? // координатор
	// MVP
	private weak var view: ProfileViewInput!
	// Sevices
	private var themeService: IThemeService!
	private var userInfoService: IUserInfoService!
	private var imageService: IImageService!
	// Requests
	private var userDataRequest: Cancellable? // для изменения данных через userInfoService
	private var updateRequest: Cancellable? // для обновления данных с EditProfileModule

	// MARK: - Inits

	/// Инициализатор презентера модуля Profile
	/// - Parameter view: Вью модуля Profile
	/// - Parameter coordinator: Координатор типа IProfileModuleOutput
	/// - Parameter userInfoService: Сервис, для работы c локальными данными об юзере
	/// - Parameter themeService: Сервис, для работы с темами приложения
	/// - Parameter imageService: Сервис, для работы с картинками из сети
	init(
		view: ProfileViewInput,
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

	/// Метод презентера, обрабатывающий нажатие кнопки edit
	public func editBtnTapped() {
		moduleOutput?.wantToOpenEditModule()
	}

	/// Метод презентера, обрабатывающий нажатие на кнопку "Загрузить" в меню способа выбора аватарки
	public func networkGalleryTapped() {
		moduleOutput?.wantToOpenNetworkGalleryModule(flow: .main)
	}

	/// Метод презентера , создающий инициалы пользователя
	/// - Parameter name: Имя юзера
	/// - Returns: Инициалы юзера
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

	/// Метод презентера, возвращающий текущую тему
	public func getCurrentTheme() -> Theme {
		themeService.getCurrentTheme()
	}

	/// Метод презентера, который сохраняет все изменения пользовальских данных в модуле
	/// - Parameter model: Модель с изменёнными данными юхера
	public func saveChanges(model: EditedProfileModel) {
		let user = convertModel(user: model)
		let queue = DispatchQueue.global(qos: .background)
		userDataRequest = userInfoService.saveUserInfo(queue: queue, user: user, image: model.avatar)
			.subscribe(on: queue, options: nil)
			.receive(on: DispatchQueue.main)
			.handleEvents(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					print(error.localizedDescription)
				}
			})
			.sink(receiveCompletion: { _ in
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDataChanged"), object: nil)
			}, receiveValue: { _ in })
	}
}

// MARK: - Private methods

extension ProfilePresenter {
	private func convertModel(user: EditedProfileModel) -> ProfileModel {
		ProfileModel(userName: user.name, userBio: user.bio)
	}
}

// MARK: - IProfileModuleInput

extension ProfilePresenter: ProfileModuleInput {
	/// Метод, который сообщает, что была выбрана аватарка пользователя из галлереи
	/// - Parameter url: url аватарки
	public func imageWasChosen(url: String) {
		let user = view.getUser()
		imageService.loadImage(from: url) { [weak self] result in
			switch result {
			case .success(let model):
				let editedProfile = EditedProfileModel(name: user.userName, bio: user.userBio, avatar: model.image)
				self?.saveChanges(model: editedProfile)
				DispatchQueue.main.async {
					self?.view.updateImageView(model: model)
				}
			case .failure(let error):
				print(error)
			}
		}
	}
}
