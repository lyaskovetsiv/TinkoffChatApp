//
//  ICoreDataLogger.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 14.04.2023.
//

import Foundation

/// Протокол для логирования ошибок и состояний при работе с CoreData
protocol ICoreDataLogger: AnyObject {
	func log(state: CoreDataState)
	func log(error: CoreDataError)
}
