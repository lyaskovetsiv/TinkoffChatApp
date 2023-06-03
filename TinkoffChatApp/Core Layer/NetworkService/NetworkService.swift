//
//  NetworkService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 24.04.2023.
//

import Foundation

/// Сервис, отвечающий за работу с сетью
final class NetworkService: INetworkService {
	// MARK: - Private properties

	private let session: URLSession = URLSession.shared

	// MARK: - Public methods

	/// Метод сервиса, отправляющий запрос в сеть и получающий ответ с  decodable T (дженерик)
	/// - Parameters:
	///   - path: Ссылка
	///   - needDecoding: Флаг, нужен ли декодинг
	///   - completion: Обработчик завершения (Result<T, Error>)
	public func sendRequest<T: Decodable>(
		path: String,
		needDecoding: Bool,
		completion: @escaping (Result<T, Error>) -> Void) {

		guard let url = URL(string: path) else {
			completion(.failure(NetworkErrors.badUrl))
			return
		}
		let urlRequest = URLRequest(url: url, timeoutInterval: 60)
		session.dataTask(with: urlRequest) { data, _, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			guard let data = data else {
				completion(.failure(NetworkErrors.badData))
				return
			}
			if needDecoding {
				do {
					let model = try JSONDecoder().decode(T.self, from: data)
					completion(.success(model))
				} catch {
					completion(.failure(NetworkErrors.badDecoding))
				}
			} else {
				if let data = data as? T {
					completion(.success(data))
				} else {
					completion(.failure(NetworkErrors.badData))
				}
			}
		}.resume()
	}
}
