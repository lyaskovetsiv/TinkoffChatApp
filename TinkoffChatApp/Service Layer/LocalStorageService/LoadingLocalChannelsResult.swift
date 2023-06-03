//
//  LoadingLocalStorageResult.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 17.04.2023.
//

import Foundation

/// Перечисление с результатом загрузки каналов из локального хранилища
enum LoadingLocalChannelsResult {
	case data([ChannelModel])
	case empty
	case error
}
