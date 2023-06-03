//
//  ChannelsErrors.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Перечисление с основными ошибками при работе с каналами
enum ChannelError: Error {
	case emptyChannelName
	case canNotLoadChannels
	case canNotDeleteChannel
	case canNotCreateChannel
	
	var description: String {
		switch self {
		case .emptyChannelName:
			return "Название канала не может быть пустым"
		case .canNotLoadChannels:
			return "Загрузка каналов c cервера прервана по техническим причинам"
		case .canNotDeleteChannel:
			return "Удаление канала на сервере прервано по техническим причинам"
		case .canNotCreateChannel:
			return "Создание канала на сервере прервано по техническим причинам"
		}
	}
}
