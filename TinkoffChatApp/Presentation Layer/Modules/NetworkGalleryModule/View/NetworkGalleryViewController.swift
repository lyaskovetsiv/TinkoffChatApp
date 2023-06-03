//
//  NetworkGalleryViewController.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 21.04.2023.
//

import UIKit

protocol IGalleryImagePicker: AnyObject {
	func imagePicked(model: ImageModel)
}

/// Вью NetworkGallery модуля
final class NetworkGalleryViewController: UIViewController {
	// MARK: - Public properties

	var presenter: NetworkGalleryViewOutput!

	// MARK: - Private constants

	private enum Constants {
		// Sizes
		static let headerStackHeight: CGFloat = 60
		static let minimumInteritemSpacing: CGFloat = 1
		static let minimumLineSpacingForSection: CGFloat = 1
		static let numberOfItemsInLine: CGFloat = 3
		
		// Fonts & Text sizes
		static let standartFontSize: CGFloat = 17
		// Constraits
		static let headerStackTrailingAnchorConstant: CGFloat = -16
		static let headerStackLeadingAnchorConstant: CGFloat = 16
	}

	// MARK: - UI

	// Header
	lazy private var cancelBtn: UIButton = {
		let btn = UIButton.makeButtonForHeader(withTitle: "Cancel")
		btn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
		return btn
	}()

	lazy private var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Select photo"
		label.font = .systemFont(ofSize: Constants.standartFontSize, weight: .bold)
		return label
	}()

	lazy private var epmtyLabel: UILabel = {
		let label = UILabel()
		return label
	}()

	lazy private var headerStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [cancelBtn, titleLabel, epmtyLabel])
		stackView.axis = .horizontal
		stackView.distribution = .equalCentering
		return stackView
	}()
	// Body
	lazy private var activityIndicator: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView()
		view.isHidden = false
		return view
	}()
	
	lazy private var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(NetworkGalleryCell.self, forCellWithReuseIdentifier: NetworkGalleryCell.identifier)
		collectionView.isHidden = true
		return collectionView
	}()

	// MARK: - LileCycleOfVC

	override func viewDidLoad() {
		super.viewDidLoad()
		setDefaultBackgroundColor()
		setupView()
	}
}

// MARK: - Private methods

extension NetworkGalleryViewController {
	private func setupView() {
		collectionView.dataSource = self
		collectionView.delegate = self
		view.addSubview(activityIndicator)
		view.addSubview(headerStack)
		view.addSubview(collectionView)
		setupConstraits()
		activityIndicator.startAnimating()
	}

	private func setupConstraits() {
		headerStack.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			headerStack.topAnchor.constraint(equalTo: view.topAnchor),
			headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.headerStackTrailingAnchorConstant),
			headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.headerStackLeadingAnchorConstant),
			headerStack.heightAnchor.constraint(equalToConstant: Constants.headerStackHeight)
		])
		
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
		
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
			collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor)
		])
	}

	@objc private func cancelBtnTapped() {
		presenter?.cancelBtnTapped()
	}
}

// MARK: - UICollectionViewDataSource

extension NetworkGalleryViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		presenter.getNumberOfItems()
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NetworkGalleryCell.identifier, for: indexPath) as? NetworkGalleryCell else {
			return UICollectionViewCell()
		}
		presenter.getCurrentItem(indexPath: indexPath) { model in
			DispatchQueue.main.async {
				cell.configure(with: model)
			}
		}
		return cell
	}
}

// MARK: - UICollectionViewDelegate

extension NetworkGalleryViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		presenter.didSelectImage(indexPath: indexPath)
	}
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NetworkGalleryViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let numberOfItemsInLine: CGFloat = Constants.numberOfItemsInLine
		let widthItem = UIScreen.main.bounds.width / numberOfItemsInLine - Constants.minimumInteritemSpacing
		let heightItem = widthItem
		return CGSize(width: widthItem, height: heightItem)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
			Constants.minimumInteritemSpacing
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		minimumLineSpacingForSectionAt section: Int) -> CGFloat {
			Constants.minimumLineSpacingForSection
	}
}

// MARK: - INetworkGalleryViewInput

extension NetworkGalleryViewController: NetworkGalleryViewInput {
	/// Метод, который скрывает индикатор активности и показывает collectionView
	public func hideActivityIndicator() {
		activityIndicator.stopAnimating()
		activityIndicator.isHidden = true
		collectionView.isHidden = false
	}

	/// Метод, обновляющий вью
	public func reloadView() {
		collectionView.reloadData()
	}
}
