//
//  CoreDataServiceProtocol.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 14.04.2023.
//

import Foundation
import CoreData

/// Протокол для работы с данными из coreData
protocol ICoreDataService: AnyObject {
	func fetchChannels() throws -> [DBChannel]
	func fetchMessages(for channelId: String) throws -> [DBMessage]
	func saveChannel(block: @escaping (NSManagedObjectContext) throws -> Void)
	func saveMessages(block: @escaping (NSManagedObjectContext) throws -> Void)
	func deleteChannel(block: @escaping (NSManagedObjectContext) throws -> Void, completion: @escaping (Result<Void, Error>) -> Void)
}
