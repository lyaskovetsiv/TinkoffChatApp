//
//  MessageInputTextField.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 05.03.2023.
//

import UIKit

/// Кастомный класс textField, используемый в Channel модуле
final class MessageInputTextField: UITextField {
	// MARK: - Private constants (UI)

	private enum Constants {
		// Sizes
		static let circleViewHeight: CGFloat = 23
		static let circleViewWidth: CGFloat = 23
		static let arrowViewHeight: CGFloat = 16
		static let arrowViewWidth: CGFloat = 16
		// Colors
		static let borderColor = #colorLiteral(red: 0.7253857255, green: 0.7253895402, blue: 0.7335650325, alpha: 1)
		static let btnColor = #colorLiteral(red: 0.2658407688, green: 0.5423326492, blue: 0.9699836373, alpha: 1)
		// Images
		static let arrowImage = UIImage(systemName: "arrow.up")
		// Fonts & Text sizes
		static let font: UIFont = .systemFont(ofSize: 17)
		// Constraits
		static let circleViewTrailingAnchorConstant: CGFloat = -7
	}

	// MARK: - UI

	lazy private var arrowView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = Constants.arrowImage?.withTintColor(.white, renderingMode: .alwaysOriginal)
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	lazy private var circleView: UIView = {
		let view = UIView()
		view.isUserInteractionEnabled = true
		view.backgroundColor = Constants.btnColor
		return view
	}()

	var buttonTappedAction: (() -> Void)?

	// MARK: - Inits

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = frame.height / 2
		layer.borderWidth = 1
		layer.borderColor = Constants.borderColor.cgColor
		clipsToBounds = true
		circleView.layer.cornerRadius = circleView.frame.height / 2
	}
}

// MARK: - Private methods

extension MessageInputTextField {
	private func setupView() {
		placeholder = "Type message"
		font = Constants.font

		setupPaddings()

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnTapped))
		circleView.addGestureRecognizer(tapGesture)

		self.addSubview(circleView)
		circleView.addSubview(arrowView)

		setupConstraits()
	}
	
	private func setupPaddings() {
		let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: frame.height))
		let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: frame.height))
		self.leftView = leftPaddingView
		self.rightView = rightPaddingView
		self.leftViewMode = .always
		self.rightViewMode = .always
	}

	private func setupConstraits() {
		circleView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			circleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			circleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: Constants.circleViewTrailingAnchorConstant),
			circleView.heightAnchor.constraint(equalToConstant: Constants.circleViewHeight),
			circleView.widthAnchor.constraint(equalToConstant: Constants.circleViewWidth)
		])

		arrowView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			arrowView.heightAnchor.constraint(equalToConstant: Constants.arrowViewHeight),
			arrowView.widthAnchor.constraint(equalToConstant: Constants.arrowViewWidth),
			arrowView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
			arrowView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
		])
	}

	@objc private func btnTapped() {
		buttonTappedAction?()
	}
}
