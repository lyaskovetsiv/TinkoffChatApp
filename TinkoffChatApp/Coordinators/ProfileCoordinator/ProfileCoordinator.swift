//
//  ProfileCoordinator.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 03.04.2023.
//

import Foundation
import UIKit

/// Координатор модулей с профайлом
final class ProfileCoordinator: ProfileModuleOutput {
	// MARK: - Private properties

	private var moduleInput: ProfileModuleInput!
	private var navigationController: UINavigationController
	private var rootVC: UIViewController!

	private var editModule: UIViewController?

	lazy private var networkModule: UIViewController = {
		let vc = ModuleAssembly.createNetworkGalleryModule(coordinator: self)
		return vc
	}()

	// MARK: - Inits

	/// Инициализатор ProfileCoordinator
	/// - Parameter navigationVC: Навигационный контроллер
	init(navigationVC: UINavigationController) {
		self.navigationController = navigationVC
		let vc = ModuleAssembly.createProfileModule(coordinator: self)
		self.navigationController.pushViewController(vc, animated: true)
		self.rootVC = vc
	}

	// MARK: - Public methods

	/// Метод координатора, который связывает презентер модуля с координатором
	/// - Parameter input: Презентер
	public func moduleDidLoad(_ input: ProfileModuleInput) {
		self.moduleInput = input
	}

	/// Метод координатора, который производит переход в модуль редактирования профиля
	public func wantToOpenEditModule() {
		let delegate = Animator(duration: 3.5, type: .present)
		editModule = ModuleAssembly.createEditProfileModule(coordinator: self)
		editModule?.transitioningDelegate = delegate
		editModule?.modalPresentationStyle = .fullScreen
		if let editModule = editModule {
			rootVC.present(editModule, animated: true)
		}
	}

	/// Метод координатора, который закрывает модуль с редактированием профиля
	public func wantToCloseEditModule() {
		let delegate = Animator(duration: 3.5, type: .dismiss)
		editModule?.transitioningDelegate = delegate
		editModule?.modalPresentationStyle = .fullScreen
		rootVC.dismiss(animated: true) { [weak self] in
			self?.editModule = nil
			self?.rootVC?.viewWillAppear(true)
		}
	}

	/// Метод координатора, который производит переход в модуль с галлереей
	public func wantToOpenNetworkGalleryModule(flow: ProfileNetworkGalleryFlow) {
		switch flow {
		case .main:
			rootVC.present(networkModule, animated: true)
		case .edit:
			editModule?.present(networkModule, animated: true)
		}
	}
}

// MARK: - NetworkGalleryModuleOutput

extension ProfileCoordinator: NetworkGalleryModuleOutput {
	/// Метод координатора, который обрабатывает закрытие галлереи изображений
	public func wantToCloseNetworkGalleryModule() {
		if networkModule.presentingViewController == self.navigationController.tabBarController {
			navigationController.dismiss(animated: true)
		} else if networkModule.presentingViewController == editModule {
			editModule?.dismiss(animated: true)
		}
	}

	/// Метод координатора, который сообщает что была выбрана картинка из галлереи
	/// - Parameter url: url картинки
	public func imageWasChosen(url: String) {
		moduleInput?.imageWasChosen(url: url)
		wantToCloseNetworkGalleryModule()
	}
}

// MARK: - IFlowCoordinator

extension ProfileCoordinator: IFlowCoordinator {

}
