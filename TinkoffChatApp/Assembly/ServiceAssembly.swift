//
//  ServiceAssembly.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 14.04.2023.
//

import Foundation

/// Класс ассембле для сервисов
final class ServiceAssembly {
	/// Метод, для сборки сервиса, работающего с чувствительными данными
	/// - Returns: Экземляр сервиса типа ISecuredDataService
	public func getSecuredDataService () -> ISecuredDataService {
		return SecuredDataService(securedDataStorage: KeyChainService())
	}

	/// Метод, для сборки сервиса, работающего с сервером
	/// - Returns: Экземляр сервиса типа IRemoteDataService
	public func getRemoteDataService() -> IRemoteDataService {
		return RemoteDataService()
	}

	/// Метод, для сборки сервиса, работающего с локальным хранилищем
	/// - Returns: Экземпляр сервиса типа ILocalDataService
	public func getLocalDataService() -> ILocalDataService {
		let logger = Logger()
		let coreDataService = CoreDataService(logger: logger)
		return LocalDataService(coreDataService: coreDataService, logger: logger)
	}

	/// Метод, для сборки сервиса, работающего с локальными данными об юзере
	/// - Returns: Экземляр сервиса типа IUserInfoService
	public func getUserInfoService() -> IUserInfoService {
		return UserInfoService(userInfoStorageService: FileManagerService())
	}

	/// Метод, для сборки сервиса, работающего с темами приложения
	/// - Returns: Экземляр сервиса типа IThemeService
	public func getThemeService () -> IThemeService {
		return ThemeService(themeStorageService: UserDefaultsService())
	}

	/// Метод, для сборки сервиса по работе c галлереей изображений
	/// - Returns: Экземляр сервиса типа IImageGalleryService
	public func getNetworkService () -> IImageService {
		return ImageService(networkService: NetworkService())
	}
}
