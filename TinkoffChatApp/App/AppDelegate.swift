//
//  AppDelegate.swift
//  TinkoffChat
//
//  Created by Ivan Lyaskovets on 18.02.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	private let securedService = ModuleAssembly.securedDataService
	private let themeService = ModuleAssembly.themeService

	var window: UIWindow?

	#if DEBUG
	static let isLogginEnabled = true
	#else
	static let isLogginEnabled = false
	#endif

	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		themeService.setupInitialTheme()
		if securedService.getStoredUserID() == nil {
			securedService.createNewUserID()
		}

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = MainViewController()
		window?.makeKeyAndVisible()

		return true
	}
}
