//
//  FontKit.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 27.02.2023.
//

import Foundation
import UIKit

/// Класс, для дополнительной обработки шрифта
final class FontKit {
	/// Метод, закругляющий шрифт
	/// - Parameters:
	///   - fontSize: Размер шрифта
	///   - weight: Насыщенность шрифта
	/// - Returns: Изменный шрифт с закруглениями
	static func roundedFont(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
		let systemFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
		let font: UIFont
		if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
			font = UIFont(descriptor: descriptor, size: fontSize)
		} else {
			font = systemFont
		}
		return font
	}
}
