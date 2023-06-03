//
//  UIButton+extension.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 19.04.2023.
//

import Foundation
import UIKit

extension UIButton {
	/// Метод, который создаёт кнопки для хэдера вью EditProfile модуля
	/// - Parameter title: Название кнопки
	/// - Returns: Кнопка типа UIButton
	static func makeButtonForHeader(withTitle title: String) -> UIButton {
		let btn = UIButton(type: .system)
		btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
		btn.setTitle(title, for: .normal)
		return btn
	}
}
