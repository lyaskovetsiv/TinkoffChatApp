//
//  UserEditView.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 19.03.2023.
//

import UIKit

/// Класс окна редактирования данных в EditProfile модуле
final class UserEditView: UIView {
	// MARK: - Private constants

	private enum Constants {
		// Sizes
		static let stackViewHeight: CGFloat = 43
		static let separatorHeight: CGFloat = 0.5
		static let viewBorderWidth: CGFloat = 0.5
		static let labelWidth: CGFloat = 96
		// Colors
		static let viewBorderColor: CGColor = #colorLiteral(red: 0.7253857255, green: 0.7253895402, blue: 0.7335650325, alpha: 1).cgColor
		static let separatorBackgroundColor: UIColor = #colorLiteral(red: 0.7253857255, green: 0.7253895402, blue: 0.7335650325, alpha: 1)
		// Constraits
		static let separatorLeadingConstant: CGFloat = 16
		static let stackViewLeadingConstant: CGFloat = 16
	}

	// MARK: - UI

	private lazy var nameLabel: UILabel = {
		let label = UILabel()
		label.text = "Name"
		return label
	}()

	private lazy var nameTextField: UITextField = {
		let tf = UITextField(frame: .zero)
		tf.attributedPlaceholder = NSAttributedString.createAttributedStringForTextField(string: "Enter your name..")
		return tf
	}()

	private lazy var bioLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.text = "Bio"
		return label
	}()

	private lazy var bioTextField: UITextField = {
		let tf = UITextField(frame: .zero)
		tf.attributedPlaceholder = NSAttributedString.createAttributedStringForTextField(string: "Enter your bio..")
		return tf
	}()

	private lazy var separator: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = Constants.separatorBackgroundColor
		return view
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

	/// Метод, делающий текстовое поле с именем пользователем first responder
	public func makeViewFirstResponder() {
		nameTextField.becomeFirstResponder()
	}

	/// Метод, снимающий first responder с вью UserInfo
	public func resignViewFirstResponder() {
		nameTextField.resignFirstResponder()
		bioTextField.resignFirstResponder()
	}

	/// Метод, возвращающий отредактированного юзера
	/// - Returns: Модель отредактированного юзера
	public func getUpdatedUser() -> ProfileModel {
		return ProfileModel(userName: nameTextField.text, userBio: bioTextField.text)
	}

	/// Метод, который настраивает данную вью
	/// - Parameters:
	///   - name: Имя юзера
	///   - bio: Описание юзера
	public func configureView(name: String?, bio: String?) {
		nameTextField.text = name
		bioTextField.text = bio
	}

	/// Метод, который обновляет фоновый цвет у вью
	public func updateBackgroundColor (theme: Theme) {
		if theme == .light {
			backgroundColor = .white
		} else {
			backgroundColor = .clear
		}
	}
}

// MARK: - Private methods

extension UserEditView {
	private func setupView() {
		layer.borderWidth = Constants.viewBorderWidth
		layer.borderColor = Constants.viewBorderColor
		nameTextField.delegate = self
		bioTextField.delegate = self
		addSubview(nameLabel)
		addSubview(nameTextField)
		addSubview(separator)
		addSubview(bioLabel)
		addSubview(bioTextField)
		setupConstraits()
	}

	private func setupConstraits() {
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 11),
			nameLabel.widthAnchor.constraint(equalToConstant: Constants.labelWidth),
			nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
		])

		nameTextField.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			nameTextField.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10),
			nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
			nameTextField.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor)
		])

		separator.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			separator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
			separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.separatorLeadingConstant),
			separator.trailingAnchor.constraint(equalTo: trailingAnchor),
			separator.centerYAnchor.constraint(equalTo: centerYAnchor)
		])

		bioLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			bioLabel.widthAnchor.constraint(equalToConstant: Constants.labelWidth),
			bioLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			bioLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11)
		])

		bioTextField.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			bioTextField.leadingAnchor.constraint(equalTo: bioLabel.trailingAnchor, constant: 10),
			bioTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
			bioTextField.centerYAnchor.constraint(equalTo: bioLabel.centerYAnchor)
		])
	}
}

// MARK: - UITextFieldDelegate

extension UserEditView: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == nameTextField {
			bioTextField.becomeFirstResponder()
		} else {
			textField.resignFirstResponder()
		}
		return true
	}
}
