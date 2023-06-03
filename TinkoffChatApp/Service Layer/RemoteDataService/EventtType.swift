//
//  EventtType.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 25.04.2023.
//

import Foundation

/// Перечисление с типом событий
enum EventtType: String, Decodable {
	case add
	case update
	case delete
}
