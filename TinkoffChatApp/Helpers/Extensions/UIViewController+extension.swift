//
//  UIViewController+extension.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 11.03.2023.
//

import Foundation
import UIKit

extension UIViewController {
	/// Метод, устанавливающий цвет контроллера в зависимости от текущей темы
	public func setDefaultBackgroundColor() {
		if ModuleAssembly.themeService.getCurrentTheme() == .light {
			view.backgroundColor = .white
		} else {
			view.backgroundColor = .black
		}
	}
}
