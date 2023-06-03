//
//  UserDataServiceProtocol.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 14.04.2023.
//

import Foundation

/// Протокол для работы с данными из FileManager
protocol IFileManagerSevice: AnyObject {
	func loadDataFromFileManager(completion: @escaping (Result<UserDataModel?, Error>) -> Void)
	func saveDataInFileManager(model: UserDataModel, completion: @escaping (Result<Void, Error>) -> Void)
	func cancel()
}
