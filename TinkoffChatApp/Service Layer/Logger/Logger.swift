//
//  CoreDataLogger.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 10.04.2023.
//

import Foundation

/// Класс, который служит для ослеживания событий и ошибок
final class Logger: ICoreDataLogger {
	// MARK: - Public methods

	/// Метод, отвечающий за логирование состояний при работе с CoreData
	/// - Parameter state: Состояние при работе с CoreData
	public func log(state: CoreDataState) {
		if AppDelegate.isLogginEnabled {
			print("CoreData: \(state.description)")
		}
	}

	/// Метод, отвечающий за логирование ошибок при работе с CoreData
	/// - Parameter error: Ошибка при работе с  CoreData
	public func log(error: CoreDataError) {
		if AppDelegate.isLogginEnabled {
			print("CoreData Error: \(error.description)")
		}
	}
}
