//
//  ImageTableViewCell.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 25.04.2023.
//

import UIKit

/// Класс ячейки таблицы  с картинкой  в Channel модуле
final class ImageTableViewCell: UITableViewCell {
	// MARK: - Private constants
	
	private enum Constants {
		static let imageCornerRadius: CGFloat = 16
		static let labelTextFont: UIFont = .systemFont(ofSize: 11)
		static let labelTextColor = #colorLiteral(red: 0.5057628155, green: 0.5055419207, blue: 0.5262123942, alpha: 1)
		static let noImage = UIImage(named: "no-image")
	}

	// MARK: - UI

	lazy private var imageMessageView: UIImageView = {
		let view = UIImageView()
		view.image = Constants.noImage
		view.layer.cornerRadius = Constants.imageCornerRadius
		view.contentMode = .scaleAspectFill
		view.clipsToBounds = true
		return view
	}()
	
	lazy private var userNameLabel: UILabel = {
		let label = UILabel()
		label.font = Constants.labelTextFont
		label.textColor = Constants.labelTextColor
		return label
	}()
	
	lazy private var dateLabel: UILabel = {
		let label = UILabel()
		label.font = Constants.labelTextFont
		label.textColor = Constants.labelTextColor
		return label
	}()
	
	// MARK: - Private properies

	// Constraits
	private lazy var leadingImageViewConstrait = NSLayoutConstraint()
	private lazy var trailingImageViewConstrait = NSLayoutConstraint()
	private lazy var topImageViewConstrait = NSLayoutConstraint()
	private lazy var leadingDateLabelConstrait = NSLayoutConstraint()
	private lazy var trailingDateLabelConstrait = NSLayoutConstraint()

	// MARK: - Inits

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		contentView.removeConstraint(topImageViewConstrait)
		topImageViewConstrait = imageMessageView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4)
		contentView.addConstraint(topImageViewConstrait)
		userNameLabel.isHidden = false
		// Constraits
		leadingImageViewConstrait.isActive = false
		trailingImageViewConstrait.isActive = false
		leadingDateLabelConstrait.isActive = false
		trailingDateLabelConstrait.isActive = false
		// Ставим ячейке значение по умолчанию
		imageMessageView.image = Constants.noImage
	}

	// MARK: - Public methods

	/// Метод ячейки для её настройки
	/// - Parameters:
	///   - model: Кортеж из данных для настройки ячейки
	///   - userID: ID текущего юзера
	public func configure(with model: (message: MessageModel, isRepeated: Bool, isLast: Bool), userID: String?) {
		guard let userID = userID else { return }
		// Clear cell
		clearCell()
		// Set constaits
		trailingImageViewConstrait = imageMessageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
		leadingImageViewConstrait = imageMessageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
		trailingDateLabelConstrait = dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
		leadingDateLabelConstrait = dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
		// Set values
		userNameLabel.text = model.message.userName
		imageMessageView.image = Constants.noImage
		dateLabel.text = Date.getFormattedDateForMessageCell(date: model.message.date)
		// Checking
		if model.message.userID == userID {
			setupOutgoingMessage()
		} else {
			setupIngoingMessage(isRepeated: model.isRepeated)
		}
	}

	/// Метод ячейки, который обновляет картинку
	/// - Parameter model: Модель с картинкой
	public func updateImage(model: ImageModel) {
		imageMessageView.image = model.image
	}
}

// MARK: - Private methods

extension ImageTableViewCell {
	private func setupView() {
		contentView.addSubview(userNameLabel)
		contentView.addSubview(imageMessageView)
		contentView.addSubview(dateLabel)
		setupConstraits()
	}

	private func setupConstraits() {
		userNameLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			userNameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 33),
			userNameLabel.widthAnchor.constraint(equalToConstant: 150)
		])

		imageMessageView.translatesAutoresizingMaskIntoConstraints = false
		topImageViewConstrait = imageMessageView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4)
		contentView.addConstraint(topImageViewConstrait)
		NSLayoutConstraint.activate([
			imageMessageView.heightAnchor.constraint(equalToConstant: 129),
			imageMessageView.widthAnchor.constraint(equalToConstant: 129)
		])

		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			dateLabel.topAnchor.constraint(equalTo: imageMessageView.bottomAnchor, constant: 4),
			dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
		])
	}

	private func clearCell() {
		imageMessageView.image = Constants.noImage
		userNameLabel.text = nil
		dateLabel.text = nil
	}

	// Настройка исходящей картинки
	private func setupOutgoingMessage() {
		// Constraits
		trailingImageViewConstrait.isActive = true
		trailingDateLabelConstrait.isActive = true
		userNameLabel.isHidden = true
		changeTopBubbleImageConstrait()
	}

	// Настройка входящей картинки
	private func setupIngoingMessage(isRepeated: Bool) {
		// Constraits
		leadingImageViewConstrait.isActive = true
		leadingDateLabelConstrait.isActive = true
		// UserNamelabel's setup
		if isRepeated {
			userNameLabel.isHidden = true
			changeTopBubbleImageConstrait()
		}
	}

	private func changeTopBubbleImageConstrait() {
		contentView.removeConstraint(topImageViewConstrait)
		topImageViewConstrait = imageMessageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4)
		topImageViewConstrait.isActive = true
	}
}

// MARK: - IReusableCell

extension ImageTableViewCell: IReusableCell {
	/// Идентификатор ячейки для переиспользования
	static var identifier: String {
		return "imageTableViewCell"
	}
}
