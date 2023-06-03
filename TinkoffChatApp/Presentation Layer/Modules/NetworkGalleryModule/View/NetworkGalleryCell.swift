//
//  NetworkGalleryCell.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 21.04.2023.
//

import UIKit

/// Класс ячейки NetworkGallery модуля
class NetworkGalleryCell: UICollectionViewCell {

	// MARK: - Private constants

	private enum Constants {
		static let noImage = UIImage(named: "no-image")
	}

	// MARK: - UI

	lazy private var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	// MARK: - Inits

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Public methods
	
	public func getImage() -> UIImage? {
		return imageView.image
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = Constants.noImage
	}
}

// MARK: - Private methods

extension NetworkGalleryCell {
	private func setupView() {
		imageView.image = Constants.noImage
		contentView.addSubview(imageView)
		setupConstraits()
	}

	private func setupConstraits() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
		])
	}
}

// MARK: - IReusableCell

extension NetworkGalleryCell: IReusableCell {
	static var identifier: String {
		return "networkGalleryCell"
	}
}

// MARK: - IConfurableViewProtocol

extension NetworkGalleryCell: IConfurableViewProtocol {
	typealias ConfigurationModel = ImageModel

	/// Метод конфигурации ячейки
	/// - Parameter model: Модель ячейки
	public func configure(with model: ImageModel) {
		imageView.image = nil
		if let image = model.image {
			imageView.image = image
		} else {
			imageView.image = Constants.noImage
		}
	}
}
