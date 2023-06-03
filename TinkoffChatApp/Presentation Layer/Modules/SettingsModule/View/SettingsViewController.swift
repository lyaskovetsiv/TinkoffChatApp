//
//  SettingsViewController.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 09.03.2023.
//

import UIKit

/// Вью Settings модуля
final class SettingsViewController: BasicViewController {
	// MARK: - Public properties

	var presenter: SettingsViewOutput!

	// MARK: - Private constants

	private enum Constants {
		// Sizes
		static let mainComposeViewHeight: CGFloat = 170
		static let buttonWidth: CGFloat = 80
		static let buttonHeight: CGFloat = 120
		static let checkMarkBorderWidth: CGFloat = 2
		static let checkMarkWidth: CGFloat = 25
		static let checkMarkHeight: CGFloat = 25
		// Colors
		static let lightThemeBackgroundColor = #colorLiteral(red: 0.9410253167, green: 0.9409405589, blue: 0.9573872685, alpha: 1)
		static let darkThemebackgroundColor = UIColor.black
		static let checkMarkBorderColor = #colorLiteral(red: 0.6822280884, green: 0.6821004748, blue: 0.6985904574, alpha: 1).cgColor
		// Images
		static let lightImage = UIImage(named: "lightButton")
		static let darkImage = UIImage(named: "darkButton")
		static let checkMarkImage = UIImage(named: "checkMark")
		// Fonts
		static let titleLabelFont: UIFont = .systemFont(ofSize: 17)
		// Constraits
		static let mainComposeViewTopAnchorConstant: CGFloat = 26
		static let mainComposeViewLeadingAnchorConstant: CGFloat = 16
		static let mainComposeViewTrailingAnchorConstant: CGFloat = -16
		static let lightButtonLeadingAnchorConstant: CGFloat = 50
		static let titleLabelTopAnchorConstant: CGFloat = 6
		static let darkButtonTrailingAnchorConstant: CGFloat = -50
		static let checkMarkTopAnchorConstant: CGFloat = 6
	}

	// MARK: - UI

	lazy private var mainComposeView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 16
		return view
	}()

	lazy private var lightButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.tag = 0
		btn.addTarget(self, action: #selector(didTapThemeButton(_:)), for: .touchUpInside)
		return btn
	}()

	lazy private var lightImageView: UIImageView = {
		let imageView = UIImageView(image: Constants.lightImage)
		imageView.backgroundColor = .clear
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	lazy private var lightTitleLabel: UILabel = {
		let label = UILabel()
		label.text = "Day"
		label.textAlignment = .center
		label.font = Constants.titleLabelFont
		return label
	}()

	lazy private var lightCheckMark: UIImageView = {
		let imageView = UIImageView()
		imageView.clipsToBounds = true
		imageView.layer.borderWidth = Constants.checkMarkBorderWidth
		imageView.layer.borderColor = Constants.checkMarkBorderColor
		imageView.layer.cornerRadius = 12.5
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	lazy private var darkButton: UIView = {
		let btn = UIButton(type: .system)
		btn.tag = 1
		btn.addTarget(self, action: #selector(didTapThemeButton(_:)), for: .touchUpInside)
		return btn
	}()

	lazy private var darkImageView: UIImageView = {
		let imageView = UIImageView(image: Constants.darkImage)
		imageView.backgroundColor = .clear
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	lazy private var darkTitleLabel: UILabel = {
		let label = UILabel()
		label.text = "Night"
		label.textAlignment = .center
		label.font = Constants.titleLabelFont
		return label
	}()

	lazy private var darkCheckMark: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.borderWidth = Constants.checkMarkBorderWidth
		imageView.layer.borderColor = Constants.checkMarkBorderColor
		imageView.layer.cornerRadius = 12.5
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	// MARK: - LifeCycleOfVC

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
}

// MARK: - Private methods

extension SettingsViewController {
	private func setupView() {
		title = "Settings"
		setDefaultBackgroundColor()
		view.addSubview(mainComposeView)
		mainComposeView.addSubview(lightButton)
		mainComposeView.addSubview(darkButton)
		lightButton.addSubview(lightImageView)
		lightButton.addSubview(lightTitleLabel)
		lightButton.addSubview(lightCheckMark)
		darkButton.addSubview(darkImageView)
		darkButton.addSubview(darkTitleLabel)
		darkButton.addSubview(darkCheckMark)
		setupConstraits()
	}

	private func setupConstraits() {
		mainComposeView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			mainComposeView.heightAnchor.constraint(equalToConstant: Constants.mainComposeViewHeight),
			mainComposeView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.mainComposeViewLeadingAnchorConstant),
			mainComposeView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.mainComposeViewTrailingAnchorConstant),
			mainComposeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.mainComposeViewTopAnchorConstant)
		])

		lightButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			lightButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
			lightButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
			lightButton.centerYAnchor.constraint(equalTo: mainComposeView.centerYAnchor),
			lightButton.leadingAnchor.constraint(equalTo: mainComposeView.leadingAnchor, constant: Constants.lightButtonLeadingAnchorConstant)
		])

		lightImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			lightImageView.topAnchor.constraint(equalTo: lightButton.topAnchor),
			lightImageView.centerXAnchor.constraint(equalTo: lightButton.centerXAnchor)
		])

		lightTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			lightTitleLabel.topAnchor.constraint(equalTo: lightImageView.bottomAnchor, constant: Constants.titleLabelTopAnchorConstant),
			lightTitleLabel.centerXAnchor.constraint(equalTo: lightButton.centerXAnchor),
			lightTitleLabel.leadingAnchor.constraint(equalTo: lightButton.leadingAnchor),
			lightTitleLabel.trailingAnchor.constraint(equalTo: lightButton.trailingAnchor)
		])

		lightCheckMark.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			lightCheckMark.topAnchor.constraint(equalTo: lightTitleLabel.bottomAnchor, constant: Constants.checkMarkTopAnchorConstant),
			lightCheckMark.centerXAnchor.constraint(equalTo: lightButton.centerXAnchor),
			lightCheckMark.widthAnchor.constraint(equalToConstant: Constants.checkMarkWidth),
			lightCheckMark.heightAnchor.constraint(equalToConstant: Constants.checkMarkHeight)
		])

		darkButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			darkButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
			darkButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
			darkButton.centerYAnchor.constraint(equalTo: mainComposeView.centerYAnchor),
			darkButton.trailingAnchor.constraint(equalTo: mainComposeView.trailingAnchor, constant: Constants.darkButtonTrailingAnchorConstant)
		])

		darkImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			darkImageView.topAnchor.constraint(equalTo: darkButton.topAnchor),
			darkImageView.centerXAnchor.constraint(equalTo: darkButton.centerXAnchor)
		])

		darkTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			darkTitleLabel.topAnchor.constraint(equalTo: darkImageView.bottomAnchor, constant: Constants.titleLabelTopAnchorConstant),
			darkTitleLabel.centerXAnchor.constraint(equalTo: darkButton.centerXAnchor),
			darkTitleLabel.leadingAnchor.constraint(equalTo: darkButton.leadingAnchor),
			darkTitleLabel.trailingAnchor.constraint(equalTo: darkButton.trailingAnchor)
		])

		darkCheckMark.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			darkCheckMark.topAnchor.constraint(equalTo: darkTitleLabel.bottomAnchor, constant: Constants.checkMarkTopAnchorConstant),
			darkCheckMark.centerXAnchor.constraint(equalTo: darkButton.centerXAnchor),
			darkCheckMark.widthAnchor.constraint(equalToConstant: Constants.checkMarkWidth),
			darkCheckMark.heightAnchor.constraint(equalToConstant: Constants.checkMarkHeight)
		])
	}

	@objc private func didTapThemeButton(_ sender: UIButton) {
		presenter.didTapThemeButton(index: sender.tag)
	}
}

// MARK: - IThemesViewInput

extension SettingsViewController: SettingsViewInput {
	/// Метод, который обновляет UI текущего контроллера, в зависимости от темы
	/// - Parameter index: Тэг нажатой кнопки
	public func updateUIWithTheme(index: Int) {
		if index == 0 {
			view.backgroundColor = Constants.lightThemeBackgroundColor
			mainComposeView.backgroundColor = .white
			darkCheckMark.image = nil
			darkCheckMark.layer.borderWidth = Constants.checkMarkBorderWidth
			lightCheckMark.image = Constants.checkMarkImage
			lightCheckMark.layer.borderWidth = 0
		} else {
			view.backgroundColor = Constants.darkThemebackgroundColor
			mainComposeView.backgroundColor = .darkGray
			lightCheckMark.image = nil
			lightCheckMark.layer.borderWidth = Constants.checkMarkBorderWidth
			darkCheckMark.image = Constants.checkMarkImage
			darkCheckMark.layer.borderWidth = 0
		}
	}
}
