//
//  Theme.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Перечисление с темами приложения
enum Theme: Int {
	case light
	case dark
	
	var description: String {
		switch self {
		case .light: return "Light"
		case .dark: return "Dark"
		}
	}
}
