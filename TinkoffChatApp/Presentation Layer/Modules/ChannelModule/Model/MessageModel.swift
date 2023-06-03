//
//  MessageModel.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 04.03.2023.
//

import Foundation
import UIKit

/// Модель Message
struct MessageModel {
	let id: String
	let userID: String
	let userName: String
	var text: String
	let date: Date
}

struct CheckedMessageModel {
	let id: String
	let userID: String
	let userName: String
	var text: String?
	var date: Date
	var image: UIImage?
	var isRepeated: Bool
	var isLast: Bool
}
