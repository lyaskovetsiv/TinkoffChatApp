//
//  ImageService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 23.04.2023.
//

import Foundation
import UIKit

///  Класс сервиса для работы с галлереей изображений
final class ImageService: IImageService {
	// MARK: - Private constants

	private var imageCache = NSCache<NSString, UIImage>()
	private var networkService: INetworkService

	// MARK: - Inits

	init(networkService: INetworkService) {
		self.networkService = networkService
	}

	// MARK: - Public methods

	/// Метод, отвечающий за загрузку списка картинок
	/// - Parameter completion: Обработчик завершения
	public func loadImageList(completion: @escaping (Result<NetworkResponseModel, Error>) -> Void) {
		let delay = DispatchTimeInterval.seconds(1)
		DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) { [weak self] in
			guard let self = self else {return}
			if let path = self.getApiUrl() {
				self.networkService.sendRequest(path: path, needDecoding: true, completion: completion)
			} else {
				completion(.failure(NetworkErrors.badUrl))
			}
		}
	}

	/// Метод, отвечающий за загрузку картинки
	/// - Parameters:
	///   - stringUrl: Ссылка на картинку
	///   - completion: Обработчик завершения
	public func loadImage(from stringUrl: String, completion: @escaping (Result<ImageModel, Error>) -> Void) {
		// Если есть картинка в кэше, грузим из кэша
		if let cachedImage = imageCache.object(forKey: NSString(string: stringUrl)) {
			let model = ImageModel(image: cachedImage)
			completion(.success(model))
		} else {
			networkService.sendRequest(path: stringUrl, needDecoding: false) { [weak self] (result: Result<Data, Error>) in
				switch result {
				case .success(let data):
					guard let image = UIImage(data: data) else {
						completion(.failure(NetworkErrors.badData))
						return
					}
					// Кэшируем изображение
					self?.imageCache.setObject(image, forKey: NSString(string: stringUrl))
					let model = ImageModel(image: image)
					completion(.success(model))
				case .failure(let error):
					completion(.failure(error))
				}
			}
		}
	}
}

// MARK: - Private methods

extension ImageService {
	private func getApiUrl() -> String? {
		guard let apiUrl = Bundle.main.object(forInfoDictionaryKey: "ApiUrl") as? String else {
			return nil
		}
		guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiTokenKey") as? String else {
			return nil
		}

		var components = apiUrl.components(separatedBy: "=")
		components[0].append(apiKey)

		return components.joined(separator: "=")
	}
}
