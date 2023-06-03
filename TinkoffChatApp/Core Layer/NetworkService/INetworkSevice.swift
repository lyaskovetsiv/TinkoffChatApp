//
//  INetworkSevice.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 26.04.2023.
//

import Foundation

/// Протокол для работы с сетью
protocol INetworkService: AnyObject {
	func sendRequest<T: Decodable>(path: String, needDecoding: Bool, completion: @escaping (Result<T, Error>) -> Void)
}
