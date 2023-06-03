//
//  ChannelsListCell.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 03.03.2023.
//

import UIKit

/// Класс ячейки таблицы ChannelsList модуля
final class ChannelsListCell: UITableViewCell {
	// MARK: - Private constants (UI)

	private enum Constants {
		// Sizes
		static let heightForImage: CGFloat = 45
		static let widthForImage: CGFloat = 45
		static let disclosureImageViewWidth: CGFloat = 6.42
		static let disclosureImageViewHeight: CGFloat = 11
		// Colors
		static let imageBackGround = #colorLiteral(red: 0.9292986393, green: 0.9293968678, blue: 0.9333828092, alpha: 1)
		static let secondTextColor = #colorLiteral(red: 0.5410659909, green: 0.5409145951, blue: 0.5574275851, alpha: 1)
		// Images
		static let dislosureImage = UIImage(systemName: "chevron.right")
		static let defaultChannelImage = UIImage(systemName: "message.circle")
		// Fonts & Text sizes
		static let initialsLabelFont: UIFont = FontKit.roundedFont(ofSize: 16, weight: .regular)
		static let standartFontSize: CGFloat = 17
		static let secondaryTextSize: CGFloat = 15
		// Constraits
		static let imageViewLeadingAnchorConstat: CGFloat = 16
		static let composeViewLeadingAnchorConstant: CGFloat = 12
		static let composeViewTrailingAnchorConstant: CGFloat = -17
		static let dateLabelTrailingAnchorConstant: CGFloat = -14
	}

	// MARK: - UI

	lazy private var channelImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		return imageView
	}()

	lazy private var channelTitleLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 1
		label.font = .systemFont(ofSize: Constants.standartFontSize, weight: .bold)
		return label
	}()

	lazy private var lastMessageLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 2
		label.textColor = Constants.secondTextColor
		label.font = .systemFont(ofSize: Constants.secondaryTextSize, weight: .regular)
		return label
	}()

	lazy private var lastDateLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 1
		label.textColor = Constants.secondTextColor
		label.font = .systemFont(ofSize: Constants.secondaryTextSize, weight: .regular)
		return label
	}()

	lazy private var disclouserImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		imageView.image = Constants.dislosureImage?.withTintColor(Constants.secondTextColor, renderingMode: .alwaysOriginal)
		return imageView
	}()

	lazy private var composeView: UIView = {
		let view = UIView()
		return view
	}()

	// MARK: - Inits
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		lastMessageLabel.font = .systemFont(ofSize: Constants.secondaryTextSize)
	}
}

// MARK: - Private methods

extension ChannelsListCell {
	private func setupView() {
		channelImageView.layer.cornerRadius = Constants.heightForImage / 2
		contentView.addSubview(channelImageView)
		contentView.addSubview(composeView)
		composeView.addSubview(channelTitleLabel)
		composeView.addSubview(disclouserImageView)
		composeView.addSubview(lastMessageLabel)
		composeView.addSubview(lastDateLabel)
		setupConstaits()
	}

	private func setupConstaits() {
		channelImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			channelImageView.widthAnchor.constraint(equalToConstant: Constants.widthForImage),
			channelImageView.heightAnchor.constraint(equalToConstant: Constants.heightForImage),
			channelImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			channelImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.imageViewLeadingAnchorConstat)
		])

		composeView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			composeView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			composeView.leadingAnchor.constraint(equalTo: channelImageView.trailingAnchor, constant: Constants.composeViewLeadingAnchorConstant),
			composeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.composeViewTrailingAnchorConstant)
		])

		channelTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			channelTitleLabel.topAnchor.constraint(equalTo: composeView.topAnchor),
			channelTitleLabel.leadingAnchor.constraint(equalTo: composeView.leadingAnchor),
			channelTitleLabel.widthAnchor.constraint(equalToConstant: 200)
		])

		disclouserImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			disclouserImageView.centerYAnchor.constraint(equalTo: channelTitleLabel.centerYAnchor),
			disclouserImageView.trailingAnchor.constraint(equalTo: composeView.trailingAnchor),
			disclouserImageView.heightAnchor.constraint(equalToConstant: Constants.disclosureImageViewHeight),
			disclouserImageView.widthAnchor.constraint(equalToConstant: Constants.disclosureImageViewWidth)
		])

		lastDateLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			lastDateLabel.centerYAnchor.constraint(equalTo: channelTitleLabel.centerYAnchor),
			lastDateLabel.trailingAnchor.constraint(equalTo: disclouserImageView.leadingAnchor, constant: Constants.dateLabelTrailingAnchorConstant)
		])

		lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			lastMessageLabel.leadingAnchor.constraint(equalTo: composeView.leadingAnchor),
			lastMessageLabel.trailingAnchor.constraint(equalTo: composeView.trailingAnchor),
			lastMessageLabel.topAnchor.constraint(equalTo: channelTitleLabel.bottomAnchor),
			lastMessageLabel.bottomAnchor.constraint(equalTo: composeView.bottomAnchor)
		])
	}
	
	private func clearCell() {
		channelImageView.image = nil
		channelTitleLabel.text = nil
		lastMessageLabel.text = nil
	}
}

// MARK: - IReusableCell

extension ChannelsListCell: IReusableCell {
	/// Идентификатор ячейки для переиспользования
	static var identifier: String {
		return "ChannelsListCell"
	}
}

// MARK: - IConfurableViewProtocol

extension ChannelsListCell: IConfurableViewProtocol {
	typealias ConfigurationModel = ChannelModel

	/// Метод, настраивающий ячейку через модель
	/// - Parameter model: Модель типа ChannelModel
	public func configure(with model: ChannelModel) {
		clearCell()
		channelTitleLabel.text = model.name
		channelImageView.image = model.image ?? Constants.defaultChannelImage
		if let message = model.lastMessage {
			lastDateLabel.text = Date.getFormattedDateForConversationCell(date: model.lastActivity) ?? ""
			lastMessageLabel.text = message
		} else {
			lastDateLabel.text = ""
			lastMessageLabel.text = "No messages yet"
			lastMessageLabel.font = .italicSystemFont(ofSize: Constants.secondaryTextSize)
		}
	}
}
