//
//  UserDataService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 20.03.2023.
//

import Foundation
import Combine

/// Класс для работы с файловой системой
final class FileManagerService: IFileManagerSevice {
	// MARK: - Private constants
	
	private enum Constants {
		static let jsonFileName = "userData.plist"
		static let imageFileName = "image.jpg"
	}

	// MARK: - Private properties

	private var saveDataWorkItem: DispatchWorkItem?
	private var savedUserData: UserDataModel?
	private var savedImageData: Data?
	private var isPerforming: Bool = false

	// MARK: - Inits
	
	init () {
		checkUserDataFile()
	}

	// MARK: - Public methods

	/// Метод, который загружает данные из файла файловой системы
	/// - Parameter completion: Замыкания завершения
	public func loadDataFromFileManager(completion: @escaping (Result<UserDataModel?, Error>) -> Void) {
		do {
			var model = UserDataModel()
			// Загружаем картинку, если она есть
			if FileManager.default.fileExists(atPath: getImageURL().path) {
				do {
					savedImageData = try Data(contentsOf: getImageURL())
					if let savedData = savedImageData {
						model.image = savedData
					}
				} catch {
					print(error.localizedDescription)
				}
			}
			// Загружаем профиль через .decode(type,decoder)
			let data = try Data(contentsOf: getFileURL())
			_ = Just(data)
				.decode(type: UserDataModel.self, decoder: PropertyListDecoder())
				.sink { completion in
					if case let .failure(error) = completion {
						print(error.localizedDescription)
					}
				} receiveValue: { value in
					model.name = value.name
					model.bio = value.bio
				}
			savedUserData = model
			completion(.success(model))
		} catch {
			completion(.failure(error))
		}
	}

	/// Метод, который сохраняет данные в файл файловой системы
	/// - Parameters:
	///   - model: Модель юзера
	///   - completion: Замыкание завершения
	public func saveDataInFileManager(model: UserDataModel, completion: @escaping (Result<Void, Error>) -> Void) {
		let fileURL = getFileURL()
		let imageURL = getImageURL()
		let saveDataItem = DispatchWorkItem { [weak self] in
			self?.isPerforming = true
			do {
				// Если обновилось имя или описание
				var savingData = Data()
				_ = Just(model)
					.encode(encoder: PropertyListEncoder())
					.sink(receiveCompletion: { completion in
						if case let .failure(error) = completion {
							print(error.localizedDescription)
						}
					}, receiveValue: { data in
						savingData = data
					})
				try savingData.write(to: fileURL)
				// Если обновилась картинка
				if let data = model.image {
					try data.write(to: imageURL)
				}
				completion(.success(()))
			} catch {
				completion(.failure(error))
			}
		}
		self.saveDataWorkItem = saveDataItem
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3) { [weak self] in
			saveDataItem.perform()
			self?.isPerforming = false
		}
	}

	/// Метод, который отвечает за  отмену сохранения данных
	public func cancel() {
		// Отменяем, если workItem, ещё не добавился в очередь
		if !isPerforming {
			saveDataWorkItem?.cancel()
		} else {
			// Переписываем значения данных на сохранённые
			DispatchQueue.global(qos: .background).async { [weak self] in
				self?.saveDataWorkItem?.perform()
			}
		}
	}
}

// MARK: - Private methods

extension FileManagerService {
	private func checkUserDataFile() {
		if !FileManager.default.fileExists(atPath: getFileURL().path) {
			do {
				let emptyUserData = UserDataModel(name: "", bio: "", image: nil)
				var data = Data()
				_ = Just(emptyUserData)
					.encode(encoder: PropertyListEncoder())
					.sink(receiveCompletion: { completion in
						if case let .failure(error) = completion {
							print(error.localizedDescription)
						}
					}, receiveValue: { encodedData in
						data = encodedData
					})
				try data.write(to: getFileURL(), options: .atomic)
			} catch {
				print(error.localizedDescription)
			}
		}
	}

	private func getFileURL() -> URL {
		let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		return documentsURL.appendingPathComponent(Constants.jsonFileName)
	}

	private func getImageURL() -> URL {
		let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		return documentsURL.appendingPathComponent(Constants.imageFileName)
	}
}
