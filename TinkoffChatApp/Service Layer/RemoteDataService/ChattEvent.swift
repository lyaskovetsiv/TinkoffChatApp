//
//  ChattEvent.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 25.04.2023.
//

import Foundation

/// Структура события с частом
struct ChattEvent: Decodable {
	let eventType: EventtType
	let resourceID: String
}
