//
//  NetworkGalleryOutput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 21.04.2023.
//

import Foundation

/// Протокол для презентера NetworkGallery модуля
protocol NetworkGalleryViewOutput: AnyObject {
	func cancelBtnTapped()
	func getNumberOfItems() -> Int
	func didSelectImage(indexPath: IndexPath)
	func getCurrentItem(indexPath: IndexPath, completion: @escaping (ImageModel) -> Void)
}
