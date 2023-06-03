//
//  MainViewController.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 31.03.2023.
//

import UIKit

/// Главный контроллер приложения
final class MainViewController: UITabBarController {
	// MARK: - Private constants

	private enum Constants {
		static let profileImage: UIImage? = UIImage(systemName: "person.crop.circle")
		static let settingsImage: UIImage? = UIImage(systemName: "gear")
		static let channelsImage: UIImage? = UIImage(systemName: "bubble.left.and.bubble.right")
	}

	private var coordinators: [IFlowCoordinator] = []

	// MARK: - LifeCycleofVC

	override func viewDidLoad() {
		super.viewDidLoad()

		let channelsVC = UINavigationController()
		let channelCoord = ChannelCoordinator(navigationVC: channelsVC)
		coordinators.append(channelCoord)
		self.setupVC(vc: channelsVC, image: Constants.channelsImage, title: "Channels")

		let settingsVC = UINavigationController(rootViewController: ModuleAssembly.createSettingsModule())
		self.setupVC(vc: settingsVC, image: Constants.settingsImage, title: "Settings")

		let profileVC = UINavigationController()
		let profileCoord = ProfileCoordinator(navigationVC: profileVC)
		coordinators.append(profileCoord)
		self.setupVC(vc: profileVC, image: Constants.profileImage, title: "Profile")

		self.viewControllers = [channelsVC, settingsVC, profileVC]
	}

	// MARK: - Private methods

	private func setupVC(vc: UINavigationController, image: UIImage?, title: String) {
		vc.tabBarItem.image = image
		vc.tabBarItem.title = title
	}
}
