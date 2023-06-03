//
//  NetworkServiceProtocol.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 23.04.2023.
//

import Foundation

/// Протокол сервиса для работы c галлереей изображений
protocol IImageService: AnyObject {
	func loadImageList(completion: @escaping (Result<NetworkResponseModel, Error>) -> Void)
	func loadImage(from stringUrl: String, completion: @escaping (Result<ImageModel, Error>) -> Void)
}
