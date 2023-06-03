//
//  NetworkGalleryLoadResult.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 23.04.2023.
//

import Foundation
import UIKit

struct NetworkResponseModel: Codable {
	let hits: [NetworkImageModel]
}

struct NetworkImageModel: Codable {
	let userImageURL: String
}

struct ImageModel {
	var image: UIImage?
}
