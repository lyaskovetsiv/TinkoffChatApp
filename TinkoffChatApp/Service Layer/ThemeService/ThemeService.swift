//
//  ThemeService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 10.03.2023.
//

import Foundation
import UIKit

/// Класс, отвечающий за работу с темами приложения
final class ThemeService: IThemeService {
	// MARK: - Private properties
	
	private var currentTheme: Theme = .light {
		didSet {
			applyTheme(self.currentTheme)
		}
	}
	
	private var themeStorageService: IUserDefaultService

	// MARK: - Inits

	init (themeStorageService: IUserDefaultService) {
		self.themeStorageService = themeStorageService
	}

	// MARK: - Public methods

	/// Метод, позволяющий получить текущую тему приложения
	/// - Returns: Текущая тема приложения
	public func getCurrentTheme() -> Theme {
		return currentTheme
	}

	/// Метод, изменяющий текущую тему
	/// - Parameter theme: Новая тема
	public func changeTheme(_ theme: Theme) {
		themeStorageService.saveTheme(theme.description)
		currentTheme = theme
	}

	/// Метод, устанавливающий стартовую тему
	public func setupInitialTheme() {
		guard let storedTheme = getStoredTheme() else {
			currentTheme = .light
			return
		}
		currentTheme = storedTheme
	}
}

// MARK: - Private methods

extension ThemeService {
	private func getStoredTheme() -> Theme? {
		if let storedTheme = themeStorageService.getStoredTheme() {
			if storedTheme == "Light" {
				return .light
			}
			return .dark
		}
		return nil
	}

	private func applyTheme(_ theme: Theme) {
		UITabBar.appearance().backgroundColor = .clear
		UINavigationBar.appearance().backgroundColor = .clear
		UITableView.appearance().backgroundColor = .clear
		UITableViewCell.appearance().backgroundColor = .clear
		UITableViewCell.appearance().selectionStyle = .none
		UINavigationBar.appearance().prefersLargeTitles = true
		UITextField.appearance(whenContainedInInstancesOf: [UIAlertController.self]).textColor = .black
		switch theme {
		case .light:
			UITabBar.appearance().barStyle = .default
			UITabBar.appearance().barTintColor = .white
			UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
			UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
			UINavigationBar.appearance().barStyle = .default
			UINavigationBar.appearance().barTintColor = .white
			UITextField.appearance().textColor = .black
			UILabel.appearance(whenContainedInInstancesOf: [UIView.self]).textColor = .black
			UITableView.appearance().overrideUserInterfaceStyle = .light
			UIActivityIndicatorView.appearance().color = .black
		case .dark:
			UITabBar.appearance().barStyle = .black
			UITabBar.appearance().barTintColor = .black
			UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
			UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
			UINavigationBar.appearance().barStyle = .black
			UINavigationBar.appearance().barTintColor = .black
			UITextField.appearance().textColor = .white
			UILabel.appearance(whenContainedInInstancesOf: [UIView.self]).textColor = .white
			UITableView.appearance().overrideUserInterfaceStyle = .dark
			UIActivityIndicatorView.appearance().color = .white
		}
		reloadViews()
	}

	private func reloadViews() {
		let windows = UIApplication.shared.windows
		for window in windows {
			for view in window.subviews {
				view.removeFromSuperview()
				window.addSubview(view)
			}
		}
	}
}
