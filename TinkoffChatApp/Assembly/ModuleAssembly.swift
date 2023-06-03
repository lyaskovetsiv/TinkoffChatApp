//
//  ModuleBuilder.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 04.03.2023.
//

import Foundation
import UIKit

/// Класс ассебле модулей (экранов)
final class ModuleAssembly {
	/// Общий паблишер для обновления данных в приложении
	static var sharedLoadPublisher = userInfoService.loadUserInfo(queue: DispatchQueue.global(qos: .background))

	static private var serviceAssembly: ServiceAssembly {
		return ServiceAssembly()
	}

	static let themeService: IThemeService = serviceAssembly.getThemeService()
	static let localDataService: ILocalDataService = serviceAssembly.getLocalDataService()
	static let securedDataService: ISecuredDataService = serviceAssembly.getSecuredDataService()
	static let userInfoService: IUserInfoService = serviceAssembly.getUserInfoService()

	/// Метод для сборки ChannelsList модуля
	/// - Parameter coordinator: Координатор IChannelCoordinator
	/// - Returns: Обьект ChannelsListViewController
	static func createChannelsListModule(coordinator: ChannelModuleOutput) -> UIViewController {
		let view = ChannelsListViewController()
		let presenter = ChannelsListPresenter(view: view,
											  coordinator: coordinator,
											  remoteDataService: serviceAssembly.getRemoteDataService(),
											  localDataService: localDataService)
		view.presenter = presenter
		
		return view
	}

	/// Метод для сборки Channel модуля
	/// - Parameters:
	///   - channel: Модель ChannelModel
	///   - corodinator: Координатор IChannelCoordinator
	/// - Returns: Обьект ChannelViewController
	static func createChannelModule(channel: ChannelModel, coordinator: ChannelModuleOutput) -> UIViewController {
		let view = ChannelViewController()
		let presenter = ChannelPresenter(view: view,
										 channel: channel,
										 coordinator: coordinator,
										 publisher: sharedLoadPublisher,
										 remoteDataService: serviceAssembly.getRemoteDataService(),
										 localDataService: localDataService,
										 securedDataService: securedDataService,
										 imageService: serviceAssembly.getNetworkService())
		view.presenter = presenter
		return view
	}

	/// Метод для сборки Settings модуля
	/// - Returns: Объект SettingsViewController
	static func createSettingsModule() -> UIViewController {
		let view = SettingsViewController()
		let presenter = SettingsPresenter(view: view,
										  themeService: themeService)
		view.presenter = presenter
		return view
	}

	/// Метод для сборки Profile модуля
	/// - Parameter coordinator: Координатор типа IProfileCoordinator
	/// - Returns: Обьект ProfileViewController
	static func createProfileModule(coordinator: ProfileModuleOutput) -> UIViewController {
		let view = ProfileViewController(publisher: sharedLoadPublisher)
		let presenter = ProfilePresenter(view: view,
										 coordinator: coordinator,
										 userInfoService: userInfoService,
										 themeService: themeService,
										 imageService: serviceAssembly.getNetworkService())
		view.presenter = presenter
		return view
	}

	/// Метод для сборки EditProfile модуля
	/// - Parameter coordinator: Координатор типа IProfileCoordinator
	/// - Returns: Объект EditProfileViewController
	static func createEditProfileModule(coordinator: ProfileModuleOutput) -> UIViewController {
		let view = EditProfileViewController(publisher: sharedLoadPublisher)
		let presenter = EditProfilePresenter(view: view,
											 coordinator: coordinator,
											 userInfoService: userInfoService,
											 themeService: themeService,
											 imageService: serviceAssembly.getNetworkService())
		view.presenter = presenter
		return view
	}

	/// Метод для сборки NetworkGallery модуля
	/// - Parameter coordinator: Координатор типа IFlowCoordinator
	/// - Returns: Объект NetworkGalleryViewController
	static func createNetworkGalleryModule(coordinator: NetworkGalleryModuleOutput) -> UIViewController {
		let view = NetworkGalleryViewController()
		let presenter = NetworkGalleryPresenter(view: view,
												coordinator: coordinator,
												networkService: serviceAssembly.getNetworkService())
		view.presenter = presenter
		return view
	}
}
