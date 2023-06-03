//
//  LoadingLocalMessagesResult.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 17.04.2023.
//

import Foundation

/// Перечисление с результатом загрузки чатов из локального хранилища
enum LoadingLocalMessagesResult {
	case data([MessageModel])
	case empty
	case error
}
