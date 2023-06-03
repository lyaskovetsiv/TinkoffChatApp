//
//  ImageErrors.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 27.04.2023.
//

import Foundation

/// Перечисление с ошибками, при работе с изображениями
enum ImageErrors: Error {
	case canNotGetImageFromData
	
	var description: String {
		switch self {
		case .canNotGetImageFromData:
			return "Ошибка при конвертации полученной data в image"
		}
	}
}
