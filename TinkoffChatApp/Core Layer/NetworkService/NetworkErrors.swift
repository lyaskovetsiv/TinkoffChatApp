//
//  NetworkErrors.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 23.04.2023.
//

import Foundation

/// Перечисление кастомных ошибок при работе с сетью
enum NetworkErrors: Error {
	case badUrl
	case badData
	case badDecoding
	case canNotLoadImage(path: String)
}

extension NetworkErrors: CustomStringConvertible {
	var description: String {
		switch self {
		case .badUrl: return "Ошибка при попытке получить URL"
		case .badData: return "Ошибка при чтении полученной data из сети"
		case .badDecoding: return "Ошибка при декодированнии данных из сети"
		case .canNotLoadImage(let path): return "Ошибка при загрузке картинки с адресом \(path)"
		}
	}
}
