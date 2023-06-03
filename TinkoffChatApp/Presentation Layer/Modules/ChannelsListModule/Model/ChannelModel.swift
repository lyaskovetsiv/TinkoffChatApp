//
//  ChannelModel.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 03.03.2023.
//

import Foundation
import UIKit

/// Модель Channel
struct ChannelModel {
	let id: String
	var name: String
	let image: UIImage?
	var lastMessage: String?
	var lastActivity: Date?
}
