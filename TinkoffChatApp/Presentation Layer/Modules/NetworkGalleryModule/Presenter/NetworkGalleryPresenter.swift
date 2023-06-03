//
//  NetworkGalleryPresenter.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 21.04.2023.
//

import Foundation

/// Презентер NetworkGallery модуля
final class NetworkGalleryPresenter: NetworkGalleryViewOutput {

	// MARK: - Private properties

	// MODULE
	private weak var moduleOutput: NetworkGalleryModuleOutput!
	// MVP
	private weak var view: NetworkGalleryViewInput!
	
	// Sevices
	private var networkService: IImageService!
	// Properties
	private var items: [NetworkImageModel] = []

	// MARK: - Inits

	init(
		view: NetworkGalleryViewInput,
		coordinator: NetworkGalleryModuleOutput,
		networkService: IImageService) {
		self.view = view
		self.moduleOutput = coordinator
		self.networkService = networkService
		loadItems()
	}

	// MARK: - Public methods

	/// Метод презентера, который делает запрос на загрузку фотографии в конкретной ячейке
	/// - Parameters:
	///   - indexPath: indexPath ячейки
	///   - completion: Обрабочик завершения
	public func getCurrentItem(indexPath: IndexPath, completion: @escaping (ImageModel) -> Void) {
		let item = items[indexPath.item]
		networkService.loadImage(from: item.userImageURL) { result in
			switch result {
			case .success(let model):
				completion(model)
			case .failure(let error):
				print(error)
				let emptyModel = ImageModel()
				completion(emptyModel)
			}
		}
	}

	/// Метод презентера, возвращающий количество картинок
	/// - Returns: Количество картинок
	public func getNumberOfItems() -> Int {
		items.count
	}

	/// Метод презентера, обрабатывающий нажатие на конкретную ячейку с картинкой
	/// - Parameter indexPath: Индекс ячейки
	public func didSelectImage(indexPath: IndexPath) {
		let item = items[indexPath.item]
		moduleOutput.imageWasChosen(url: item.userImageURL)
	}

	/// Метод презентера, обрабатывающий нажатие на кнопку "Cancel"
	public func cancelBtnTapped() {
		moduleOutput.wantToCloseNetworkGalleryModule()
	}
}

// MARK: - Private methods

extension NetworkGalleryPresenter {
	private func loadItems() {
		networkService.loadImageList { [weak self] result in
			switch result {
			case .success(let downloadedItems):
				DispatchQueue.main.async {
					self?.items = downloadedItems.hits
					self?.view.hideActivityIndicator()
					self?.view.reloadView()
				}
			case .failure(let error):
				print(error)
			}
		}
	}
}
