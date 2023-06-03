//
//  NSAttributedString+extension.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 19.03.2023.
//

import Foundation
import UIKit

extension NSAttributedString {
	/// Метод, единый плейсхолдер для текстового поля
	/// - Parameter string: Текст для плейсхолдера
	/// - Returns:Плейсхолдер
	static func createAttributedStringForTextField(string: String) -> NSAttributedString {
		return NSAttributedString(string: string,
								  attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
	}
}
