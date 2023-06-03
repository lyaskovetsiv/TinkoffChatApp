//
//  CoreDataService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 07.04.2023.
//

import Foundation
import CoreData

/// Класс для работы с CoreData
final class CoreDataService: ICoreDataService {
	// MARK: - Private properties

	private lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Chat")
		container.loadPersistentStores { [weak self] _, error in
			guard let error else { return }
			self?.logger.log(error: .canNotConnectToStorage)
			print(error.localizedDescription)
		}
		return container
	}()
	
	private var logger: ICoreDataLogger!

	private var viewContext: NSManagedObjectContext {
		persistentContainer.viewContext
	}

	// MARK: - Inits
	
	init(logger: ICoreDataLogger) {
		self.logger = logger
	}

	// MARK: - Public methods

	/// Метод, возвращающий из coreData отсортированный массив по дате последнего сообщения с DBChannel
	/// - Returns: Массив DBChannel
	public func fetchChannels() throws -> [DBChannel] {
		let fetchRequst = DBChannel.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "lastActivity", ascending: false)
		let sortDescriptor2 = NSSortDescriptor(key: "name", ascending: true)
		fetchRequst.sortDescriptors = [sortDescriptor, sortDescriptor2]
		return try viewContext.fetch(fetchRequst)
	}

	/// Метод, который удаляет канал и его сообщения из coreData
	/// - Parameter block: Замыкание с контекстом, которое может выбросить ошибку
	/// - Parameter completion:  Комплишен типа (Result<Void, Error>) -> Void)
	public func deleteChannel(block: @escaping (NSManagedObjectContext) throws -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
		let backgroundContext = persistentContainer.newBackgroundContext()
		backgroundContext.perform {
			do {
				try block(backgroundContext)
				if backgroundContext.hasChanges {
					try backgroundContext.save()
				}
				completion(.success(()))
			} catch {
				completion(.failure(error))
			}
		}
	}

	/// Метод, возвращающий из coreData массив с DBMessages
	public func fetchMessages(for channelId: String) throws -> [DBMessage] {
		// Получаем конкретный канал из coreData
		let fetchRequest = DBChannel.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id == %@", channelId as CVarArg)
		guard let dbChannel = try viewContext.fetch(fetchRequest).first else {
			logger.log(error: .canNotFetchChannel)
			return []
		}
		// Если массива с сообщениями нет - возвращаем пустой массив
		guard let dbMessages = dbChannel.messages?.array as? [DBMessage] else {
			return []
		}
		return dbMessages
	}
	
	/// Метод, который сохраняет каналы в coreData
	/// - Parameter block: Замыкание с контекстом, которое может выбросить ошибку
	public func saveChannel(block: @escaping (NSManagedObjectContext) throws -> Void) {
		let backgroundContext = persistentContainer.newBackgroundContext()
		backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		backgroundContext.perform { [weak self] in
			do {
				try block(backgroundContext)
				if backgroundContext.hasChanges {
					try backgroundContext.save()
				}
			} catch {
				self?.logger.log(error: .canNotSaveChannels)
				print(error.localizedDescription)
			}
		}
	}

	/// Метод, который сохраняет сообщения в coreData
	/// - Parameter block: Замыкание с контекстом, которое может выбросить ошибку
	public func saveMessages(block: @escaping (NSManagedObjectContext) throws -> Void) {
		let backgroundContext = persistentContainer.newBackgroundContext()
		backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		backgroundContext.perform { [weak self] in
			do {
				try block(backgroundContext)
				if backgroundContext.hasChanges {
					try backgroundContext.save()
				}
			} catch {
				self?.logger.log(error: .cantNotSaveMessages)
				print(error.localizedDescription)
			}
		}
	}
}
