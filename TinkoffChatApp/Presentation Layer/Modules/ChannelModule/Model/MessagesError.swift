//
//  MessagesError.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Перечисление с основными ошибками при работе с сообщениями
enum MessagesErrors {
	case canNotLoadMessages
	case canNotSendMessage
	case emptyMessage

	var description: String {
		switch self {
		case .canNotLoadMessages:
			return "Загрузка сообщений прервана по техническим причинам"
		case .canNotSendMessage:
			return "Отправка сообщения прервана по техническим причинам"
		case .emptyMessage:
			return "Сообщение не может быть пустым"
		}
	}
}
