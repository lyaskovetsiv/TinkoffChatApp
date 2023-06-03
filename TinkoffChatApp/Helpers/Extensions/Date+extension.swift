//
//  Date+extension.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 14.03.2023.
//

import Foundation

extension Date {
	/// Метод получения форматированной даты для ячейки ConversationTableViewCell
	/// - Parameter date: Дата
	/// - Returns: Форматрированная дата (String)
	static func getFormattedDateForConversationCell(date: Date?) -> String? {
		guard let date = date else {
			return nil
		}
		let dateFormatter = DateFormatter()
		if date < Calendar.current.startOfDay(for: Date()) {
			dateFormatter.dateFormat = "dd MMM"
		} else {
			dateFormatter.dateFormat = "HH:mm"
		}
		return dateFormatter.string(from: date)
	}

	/// Метод получения форматированной даты для ячейки MessageTableViewCell
	/// - Parameter date: Дата
	/// - Returns: Форматрированная дата (String)
	static func getFormattedDateForMessageCell(date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
		return formatter.string(from: date)
	}
}
