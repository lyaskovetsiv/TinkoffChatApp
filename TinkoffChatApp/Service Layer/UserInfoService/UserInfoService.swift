//
//  UserInfoService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 17.04.2023.
//

import Foundation
import Combine
import UIKit

/// Класс сервиса для работы с информацией об юзере
final class UserInfoService: IUserInfoService {
	// MARK: - Private properties

	private var userInfoStorageService: IFileManagerSevice!

	// MARK: - Inits

	init (userInfoStorageService: IFileManagerSevice) {
		self.userInfoStorageService = userInfoStorageService
	}

	// MARK: - Public methods

	/// Метод, который локально сохраняет данные об юзере
	/// - Parameters:
	///   - queue: Очередь сохранения
	///   - user: Модель юзера
	///   - image: Аватарка бзера
	/// - Returns: Паблишер типа AnyPublisher<Void, Error>
	public func saveUserInfo(queue: DispatchQueue, user: ProfileModel, image: UIImage?) -> AnyPublisher<Void, Error> {
		Deferred {
			Future { promise in
				queue.async { [weak self] in
					var model = UserDataModel(name: user.userName, bio: user.userBio)
					if let image = image {
						let imageData = image.jpegData(compressionQuality: 0.7)
						model.image = imageData
					}
					self?.userInfoStorageService.saveDataInFileManager(model: model, completion: { result in
						promise(result)
					})
				}
			}
		}
		.eraseToAnyPublisher()
	}

	/// Метод, который загружает локальные данные об юзере
	/// - Parameter queue: Очередь загрузки
	/// - Returns: Паблишер типа AnyPublisher<(ProfileModel?, UIImage?), Error>
	public func loadUserInfo(queue: DispatchQueue) -> AnyPublisher<(ProfileModel?, UIImage?), Error> {
		Deferred {
			Future { promise in
				queue.async { [weak self] in
					self?.userInfoStorageService.loadDataFromFileManager(completion: { result in
						let mappedResult = result
							.map { model in
								var profile: ProfileModel? = ProfileModel()
								var image: UIImage?
								profile?.userName = model?.name
								profile?.userBio = model?.bio
								if let data = model?.image {
									image = UIImage(data: data)
								}
								return (profile, image)
						}
						promise(mappedResult)
					})
				}
			}
		}
		.eraseToAnyPublisher()
	}

	/// Метод, который отменяет сохранение данных и возвращает предыдущие значения данных об юзере
	public func cancelSaving() {
		userInfoStorageService.cancel()
	}
}
