//
//  CoreDataStates.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 14.04.2023.
//

import Foundation

/// Перечисление состояний при работе с CoreData (для логирования)
enum CoreDataState {
	case channelsLoaded(count: Int)
	case messagesLoaded(count: Int)
	case loadingChannels
	case loadingMessages(id: String)
	case checkingChannelsInLocalStore
	case checkingMessagesInLocalStore
	case finishedCheckingChannelsInLocalStore
	case finishedCheckingMessagesInLocalStore
	case messageSaved(id: String)
	case channelSaved(id: String)
	case deletingChannel
	case channelWasDeleted
	case trashChannelFound(id: String)
	case chekingTrashChannelsInLocalStore

	var description: String {
		switch self {
		case .channelsLoaded(let count):
			return "Загрузка каналов успешно завершена. Количество каналов: \(count)"
		case .messagesLoaded(let count):
			return "Загрузка сообщений успешно завершена. Количество сообщений: \(count)"
		case .loadingChannels:
			return "Загружаем каналы"
		case .loadingMessages(let id):
			return "Загружаем сообщения для канала (id: \(id))"
		case .checkingChannelsInLocalStore:
			return "Сверяем полученные каналы из сети с сохранёнными каналами"
		case .checkingMessagesInLocalStore:
			return "Сверяем полученные сообщения из сети с сохранёнными сообщениями"
		case .finishedCheckingChannelsInLocalStore:
			return "Сверка полученных каналов из сервера с сохранёнными успешно завершена"
		case .messageSaved(let id):
			return "Добавлено новое сообщение (id: \(id))"
		case .deletingChannel:
			return "Удаляем канал"
		case .channelWasDeleted:
			return "Канал был успешно удалён"
		case .finishedCheckingMessagesInLocalStore:
			return "Сверка полученных сообщений из сервера с сохранёнными успешно завершена"
		case .channelSaved(let id):
			return "Добавлен новый канал (id: \(id))"
		case .trashChannelFound(let id):
			return "Найден канал, удалённый на сервере. Данный канал будет удалён (id: \(id))"
		case .chekingTrashChannelsInLocalStore:
			return "Проверка каналов в хранилище на наличие, удалённых каналов на севере, успешно завершена."
		}
	}
}
