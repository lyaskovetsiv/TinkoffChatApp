//
//  ChannelCoordinator.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 31.03.2023.
//

import Foundation
import UIKit

/// Координатор модулей с чатами
final class ChannelCoordinator: ChannelModuleOutput {
	// MARK: - Private properties
	
	private var moduleInput: ChannelModuleInput!
	private var navigationController: UINavigationController
	private var rootVC: UIViewController?
	
	// MARK: - Inits

	/// Инициализатор ChannelCoordinator
	/// - Parameter navigationVC: Навигационный контроллер
	init(navigationVC: UINavigationController) {
		self.navigationController = navigationVC
		let vc = ModuleAssembly.createChannelsListModule(coordinator: self)
		self.navigationController.pushViewController(vc, animated: true)
		self.rootVC = vc
	}

	// MARK: - Public methods

	/// Метод координатора, который настраивает input модуля
	/// - Parameter input: Инпут модуля
	public func moduleDidLoad(_ input: ChannelModuleInput) {
		self.moduleInput = input
	}

	/// Метод координатора, который производит закрытие экрана с конкретным чатом
	public func wantToCloseChannelModule() {
		navigationController.popViewController(animated: true)
	}

	/// Метод координатора, который производит переход в окно с конкретным чатом
	/// - Parameter model: Модель с юзером
	public func wantToOpenChannelModule(model: ChannelModel) {
		let vc = ModuleAssembly.createChannelModule(channel: model, coordinator: self)
		self.navigationController.pushViewController(vc, animated: true)
	}
	
	/// Метод координатора, который производит переход в модуль с галлереей
	public func wantToOpenNetworkGalleryModule() {
		let vc = ModuleAssembly.createNetworkGalleryModule(coordinator: self)
		rootVC?.present(vc, animated: true)
	}
}

// MARK: - NetworkGalleryModuleOutput

extension ChannelCoordinator: NetworkGalleryModuleOutput {
	/// Метод координатора, который говорит нам о том, что было выбрано изображение из галлереи
	/// - Parameter url: url изображения
	public func imageWasChosen(url: String) {
		moduleInput.imageWasChosen(url: url)
		rootVC?.dismiss(animated: true)
	}
	
	/// Метод координатора, который осуществляет закрытие модуля с галлереей изображений
	public func wantToCloseNetworkGalleryModule() {
		rootVC?.dismiss(animated: true)
	}
}

// MARK: - IFlowCoordinator

extension ChannelCoordinator: IFlowCoordinator {

}
