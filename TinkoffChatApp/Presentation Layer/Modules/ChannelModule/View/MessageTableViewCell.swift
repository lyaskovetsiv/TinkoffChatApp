//
//  MessageTableViewCell.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 05.03.2023.
//

import UIKit

/// Класс ячейки таблицы с текстом в Channel модуле
final class MessageTableViewCell: UITableViewCell {
	// MARK: - Private constants

	private enum Constants {
		// Sizes
		static let bubbleImageInsets: UIEdgeInsets = UIEdgeInsets(top: 15, left: 18, bottom: 15, right: 18)
		static let messageLabelWidth: CGFloat = 28
		static let textCountInLineBubble: Int = 35
		static let messageWidth: CGFloat = 220
		static let tailBubbleViewWidth: CGFloat = 10
		static let tailBubbleViewHeight: CGFloat = 10
		static let userNameLabelWidth: CGFloat = 150
		// Colors
		static let outgoingDateLabelTextColor = #colorLiteral(red: 0.6586056352, green: 0.7690122724, blue: 0.9642433524, alpha: 1)
		static let ingoingDateLabelTextColor = #colorLiteral(red: 0.5057628155, green: 0.5055419207, blue: 0.5262123942, alpha: 1)
		static let outgoingViewColor = #colorLiteral(red: 0.2658721209, green: 0.5423000455, blue: 0.9700840116, alpha: 1)
		static let ingoingViewColor = #colorLiteral(red: 0.9137008786, green: 0.9135787487, blue: 0.9218893647, alpha: 1)
		static let outgoingMessageLabelColor = UIColor.white
		static let ingoingMessageLabelTextColor = UIColor.black
		// Images
		static let ingoingTailBubbleImage: UIImage? = UIImage(named: "incommingTail")
		static let outgoingTailBubbleImage: UIImage? = UIImage(named: "outcommingTail")
		// Fonts & Text Properties
		static let messageLabelTextFont: UIFont = .systemFont(ofSize: 17)
		static let dateLabelTextFont: UIFont = .systemFont(ofSize: 10)
		static let userNameLabelTextFont: UIFont = .systemFont(ofSize: 11)
		// Constraits
		static let bubleViewTopAnchorConstant: CGFloat = 4
		static let bubleViewBottomAnchorConstant: CGFloat = -4
		static let bubleViewWidthMultiplier = 0.75
		static let bubbleViewTrailingAnchorConstant: CGFloat = -20
		static let bubbleViewLeadingAnchorConstant: CGFloat = 20
		static let messageLabelTopAnchorConstant: CGFloat = 6
		static let messageLabelBottomAnchorConstant: CGFloat = -6
		static let messageLabelLeadingAnchorConstant: CGFloat = 16
		static let dateLabelBottomAnchorConstant: CGFloat = -6
		static let dateLabelTrailingAnchorConstant: CGFloat = -16
		static let dateLabelLeadingAnchorConstant: CGFloat = 4
		static let userNameLabelTopAnchorConstant: CGFloat = 8
		static let userNameLabelLeadingAnchorConstant: CGFloat = 33
		static let tailBubbleViewBottomAnchorConstant: CGFloat = -5
		static let tailBubbleViewLeadingAnchor: CGFloat = 18
		static let tailBubbleViewTrailingAnchor: CGFloat = -18
	}

	// MARK: - UI

	lazy private var userNameLabel: UILabel = {
		let label = UILabel()
		label.font = Constants.userNameLabelTextFont
		label.textColor = Constants.ingoingDateLabelTextColor
		return label
	}()

	lazy private var messageLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.textAlignment = .left
		label.font = Constants.messageLabelTextFont
		return label
	}()

	lazy private var dateLabel: UILabel = {
		let label = UILabel()
		label.font = Constants.dateLabelTextFont
		return label
	}()
	
	lazy private var messageImageView: UIImageView = {
		let imageView = UIImageView()
		return imageView
	}()

	lazy private var bubbleView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 14
		return view
	}()

	lazy private var tailBubbleView: UIImageView = {
		let imageView = UIImageView()
		return imageView
	}()

	// MARK: - Private properies

	private lazy var leadingBubleViewConstrait = NSLayoutConstraint()
	private lazy var trailingBubbleViewConstrait = NSLayoutConstraint()
	private lazy var topBubbleViewConstrait = NSLayoutConstraint()

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
		contentView.removeConstraint(topBubbleViewConstrait)
		topBubbleViewConstrait = bubbleView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: Constants.bubleViewTopAnchorConstant)
		contentView.addConstraint(topBubbleViewConstrait)
		leadingBubleViewConstrait.isActive = false
		trailingBubbleViewConstrait.isActive = false
		userNameLabel.isHidden = false
		tailBubbleView.removeFromSuperview()
	}

	// MARK: - Public Methods

	/// Метод ячейки для её настройки
	/// - Parameters:
	///   - model: Кортеж из данных для настройки ячейки
	///   - userID: ID текущего юзера
	public func configure(with model: (message: MessageModel, isRepeated: Bool, isLast: Bool), userID: String?) {
		guard let userID = userID else { return }
		clearCell()
		// Set constaits
		trailingBubbleViewConstrait = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.bubbleViewTrailingAnchorConstant)
		leadingBubleViewConstrait = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.bubbleViewLeadingAnchorConstant)
		// Set values
		userNameLabel.text = model.message.userName
		messageLabel.text = model.message.text
		dateLabel.text = Date.getFormattedDateForMessageCell(date: model.message.date)
		// Checking
		if model.message.userID == userID {
			setupOutgoingMessage(isLast: model.isLast)
		} else {
			setupIngoingMessage(isRepeated: model.isRepeated, isLast: model.isLast)
		}
	}
}

// MARK: - Private methods

extension MessageTableViewCell {
	private func setupView() {
		contentView.addSubview(userNameLabel)
		contentView.addSubview(bubbleView)
		bubbleView.addSubview(messageLabel)
		bubbleView.addSubview(dateLabel)
		setupConstraits()
	}

	private func setupConstraits() {
		userNameLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.userNameLabelTopAnchorConstant),
			userNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.userNameLabelLeadingAnchorConstant),
			userNameLabel.widthAnchor.constraint(equalToConstant: Constants.userNameLabelWidth)
		])
		
		bubbleView.translatesAutoresizingMaskIntoConstraints = false
		topBubbleViewConstrait = bubbleView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: Constants.bubleViewTopAnchorConstant)
		contentView.addConstraint(topBubbleViewConstrait)
		NSLayoutConstraint.activate([
			bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.bubleViewBottomAnchorConstant),
			bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: Constants.bubleViewWidthMultiplier)
		])

		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: Constants.messageLabelTopAnchorConstant),
			messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: Constants.messageLabelBottomAnchorConstant),
			messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Constants.messageLabelLeadingAnchorConstant),
			messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.messageWidth)
		])

		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			dateLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: Constants.dateLabelBottomAnchorConstant),
			dateLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: Constants.dateLabelTrailingAnchorConstant),
			dateLabel.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: Constants.dateLabelLeadingAnchorConstant)
		])
	}

	private func setupOutgoingMessage(isLast: Bool) {
		// Colors
		bubbleView.backgroundColor = Constants.outgoingViewColor
		messageLabel.textColor = Constants.outgoingMessageLabelColor
		dateLabel.textColor = Constants.outgoingDateLabelTextColor
		// Constraits
		trailingBubbleViewConstrait.isActive = true
		userNameLabel.isHidden = true
		changeTopBubbleImageConstrait()
		// Tail's setup
		if isLast {
			setupTail(isOutgoing: true)
		}
	}

	private func setupIngoingMessage(isRepeated: Bool, isLast: Bool) {
		// Colors
		bubbleView.backgroundColor = Constants.ingoingViewColor
		messageLabel.textColor = Constants.ingoingMessageLabelTextColor
		dateLabel.textColor = Constants.ingoingDateLabelTextColor
		// Constraits
		leadingBubleViewConstrait.isActive = true
		// UserNamelabel's setup
		if  isRepeated {
			userNameLabel.isHidden = true
			changeTopBubbleImageConstrait()
		}
		// Tail's setup
		if isLast {
			setupTail(isOutgoing: false)
		}
	}

	private func setupTail(isOutgoing: Bool) {
		contentView.addSubview(tailBubbleView)
		tailBubbleView.image = isOutgoing ? Constants.outgoingTailBubbleImage : Constants.ingoingTailBubbleImage
		tailBubbleView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tailBubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.tailBubbleViewBottomAnchorConstant),
			tailBubbleView.widthAnchor.constraint(equalToConstant: Constants.tailBubbleViewWidth),
			tailBubbleView.heightAnchor.constraint(equalToConstant: Constants.tailBubbleViewHeight)
		])
		if isOutgoing {
			tailBubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.tailBubbleViewTrailingAnchor).isActive = true
		} else {
			tailBubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.tailBubbleViewLeadingAnchor).isActive = true
		}
	}

	private func changeTopBubbleImageConstrait() {
		contentView.removeConstraint(topBubbleViewConstrait)
		topBubbleViewConstrait = bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.bubleViewTopAnchorConstant)
		topBubbleViewConstrait.isActive = true
	}
	
	private func clearCell() {
		messageImageView.image = nil
		userNameLabel.text = nil
		dateLabel.text = nil
		messageLabel.text = nil
	}
}

// MARK: - IReusableCell

extension MessageTableViewCell: IReusableCell {
	/// Идентификатор ячейки для переиспользования
	static var identifier: String {
		return "messageTableViewCell"
	}
}
