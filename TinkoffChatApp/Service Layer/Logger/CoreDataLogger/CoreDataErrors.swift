//
//  CoreDataErrors.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Перечисление ошибок при работе с CoreData (для логирования)
enum CoreDataError: Error {
	case canNotFetchChannel
	case canNotFetchChannels
	case canNotDeleteChannel
	case canNotSaveChannels
	case canNotFetchMessages
	case cantNotSaveMessages
	case canNotConnectToStorage
	
	var description: String {
		switch self {
		case .canNotFetchChannel:
			return "Ошибка при загрузке текущего канала"
		case .canNotFetchChannels:
			return "Ошибка при загрузке каналов"
		case .canNotDeleteChannel:
			return "Ошибка при удалении текущего канала"
		case .canNotSaveChannels:
			return "Ошибка при сохранении каналов"
		case .canNotFetchMessages:
			return "Ошибка при загрузке сообщений"
		case .cantNotSaveMessages:
			return "Ошибка при сохранении сообщений"
		case .canNotConnectToStorage:
			return "Ошибка при подключении к storage"
		}
	}
}
