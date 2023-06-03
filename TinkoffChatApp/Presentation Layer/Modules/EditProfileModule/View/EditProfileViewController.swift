//
//  EditProfileViewController.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 24.02.2023.
//

import UIKit
import Combine

/// Вью EditProfile модуля
final class EditProfileViewController: BasicViewController {
	// MARK: - Public properties

	var presenter: EditProfileViewOutput!

	// MARK: - Private constants

	private enum Constants {
		// Sizes
		static let userImageViewHeight: CGFloat = 150
		static let userImageViewWidth: CGFloat = 150
		static let unknownImageViewHeight: CGFloat = 90
		static let unknownImageViewWidth: CGFloat = 90
		static let headerStackHeight: CGFloat = 60
		static let userEditViewHeight: CGFloat = 88
		// Colors
		static let userInfoLabelTextColor = #colorLiteral(red: 0.5410659909, green: 0.5409145951, blue: 0.5574275851, alpha: 1)
		static let lightBackgroundColor = #colorLiteral(red: 0.9488552213, green: 0.9487094283, blue: 0.9693081975, alpha: 1)
		static let unknownImageColor = #colorLiteral(red: 0.533272922, green: 0.5333681703, blue: 0.5332669616, alpha: 1)
		// Images
		static let unknownUserImage: UIImage? = UIImage(systemName: "person.fill")?.withTintColor(unknownImageColor, renderingMode: .alwaysOriginal)
		// Fonts & Text sizes
		static let standartFontSize: CGFloat = 17
		static let enlargedFontSize: CGFloat = 22
		static let initalsLabelFont: UIFont = FontKit.roundedFont(ofSize: 70, weight: .regular)
		// Constraits
		static let headerStackTrailingAnchorConstant: CGFloat = -16
		static let headerStackLeadingAnchorConstant: CGFloat = 16
		static let userImageViewTopAnchorConstant: CGFloat = 32
		static let addPhotoBtnTopAnchorConstant: CGFloat = 24
		static let userEditViewTopAnchorConstant: CGFloat = 24
		static let userEditViewLeadingAnchorConstant: CGFloat = -1
		static let userEditViewTrailingAnchorConstant: CGFloat = 1
	}

	// MARK: - Private properties

	// UI
	lazy private var cancelBtn: UIButton = {
		let btn = UIButton.makeButtonForHeader(withTitle: "Cancel")
		btn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
		return btn
	}()

	lazy private var saveBtn: UIButton = {
		let btn = UIButton.makeButtonForHeader(withTitle: "Save")
		btn.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
		return btn
	}()
	
	lazy private var addPhotoBtn: UIButton = {
		let btn = UIButton.makeButtonForHeader(withTitle: "Add Photo")
		btn.addTarget(self, action: #selector(createChooseImageAlertVC), for: .touchUpInside)
		return btn
	}()

	lazy private var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Edit Profile"
		label.font = .systemFont(ofSize: Constants.standartFontSize, weight: .bold)
		return label
	}()

	lazy private var activityIndicator: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView(frame: .zero)
		return activityIndicator
	}()

	lazy private var headerStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [cancelBtn, titleLabel, saveBtn])
		stackView.axis = .horizontal
		stackView.distribution = .equalCentering
		return stackView
	}()

	lazy private var userImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = Constants.userImageViewHeight / 2
		return imageView
	}()

	lazy private var initialsLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.font = Constants.initalsLabelFont
		label.textAlignment = .center
		return label
	}()

	lazy private var userEditView: UserEditView = {
		let view = UserEditView(frame: .zero)
		return view
	}()
	// Publishers&Requests
	private var loadPublisher: AnyPublisher<(ProfileModel?, UIImage?), Error>
	private var dataRequest: Cancellable?
	// Other
	private enum State {
		case loading
		case loaded(ProfileModel?, UIImage?)
	}
	private var state: State = .loading {
		didSet {
			if case let .loaded(profile, image) = state {
				configureView(profile: profile, image: image)
			}
		}
	}
	private var imagePicker: UIImagePickerController!
	private var pickedImage: UIImage?

	// MARK: - Inits

	init(publisher: AnyPublisher<(ProfileModel?, UIImage?), Error>) {
		self.loadPublisher = publisher
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - LifeCycleOfViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadUser()
		setupView()
		presenter.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateColors()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		presenter.viewWillDissapear()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if userImageView.image == nil {
			CAGradientLayer.createGradient(for: userImageView)
		} else {
			userImageView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
		}
	}
}

// MARK: - Private methods

extension EditProfileViewController {
	private func loadUser() {
		state = .loading
		dataRequest = loadPublisher
			.subscribe(on: DispatchQueue.global(qos: .background), options: nil)
			.receive(on: DispatchQueue.main, options: nil)
			.catch({ _ in Just(( nil, nil)) })
					.map { result in State.loaded(result.0, result.1) }
			.assign(to: \.state, on: self)
	}

	// Setup view
	private func setupView() {
		navigationItem.largeTitleDisplayMode = .never
		setDefaultBackgroundColor()
		setupImageController()
		setupGestures()
		view.addSubview(headerStack)
		view.addSubview(userImageView)
		view.addSubview(addPhotoBtn)
		view.addSubview(userEditView)
		setupConstraits()
		// userEditView.makeViewFirstResponder()
	}

	private func setupImageController () {
		imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
	}

	private func setupGestures() {
		let mainTapGesture = UITapGestureRecognizer(target: self, action: #selector(makeMainViewFirstResponder))
		view.addGestureRecognizer(mainTapGesture)
	}

	private func setupConstraits() {
		headerStack.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			headerStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
			headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.headerStackTrailingAnchorConstant),
			headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.headerStackLeadingAnchorConstant),
			headerStack.heightAnchor.constraint(equalToConstant: Constants.headerStackHeight)
		])

		userImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			userImageView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: Constants.userImageViewTopAnchorConstant),
			userImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			userImageView.widthAnchor.constraint(equalToConstant: Constants.userImageViewWidth),
			userImageView.heightAnchor.constraint(equalToConstant: Constants.userImageViewHeight)
		])

		addPhotoBtn.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			addPhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			addPhotoBtn.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: Constants.addPhotoBtnTopAnchorConstant)
		])

		userEditView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			userEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.userEditViewLeadingAnchorConstant),
			userEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.userEditViewTrailingAnchorConstant),
			userEditView.topAnchor.constraint(equalTo: addPhotoBtn.bottomAnchor, constant: Constants.userEditViewTopAnchorConstant),
			userEditView.heightAnchor.constraint(equalToConstant: Constants.userEditViewHeight)
		])
	}

	private func updateColors() {
		let currentTheme = presenter.getCurrentTheme()
		view.backgroundColor = currentTheme == .light ? Constants.lightBackgroundColor : .black
		userEditView.updateBackgroundColor(theme: currentTheme)
	}

	// Configure view with data
	private func configureView(profile: ProfileModel?, image: UIImage?) {
		// Настраиваем текстовые поля
		userEditView.configureView(name: profile?.userName ?? "", bio: profile?.userBio ?? "")
		// Настраиваем аватарку юзера
		if let image {
			configureViewWithImage(image: image)
		} else {
			configureViewWithoutImage(userName: profile?.userName)
		}
	}
	
	private func configureViewWithImage(image: UIImage) {
		initialsLabel.removeFromSuperview()
		userImageView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
		userImageView.image = image
	}
	
	private func configureViewWithoutImage(userName: String?) {
		if let userName = userName, userName.trimmingCharacters(in: .whitespaces) != "" {
			userImageView.image = nil
			createInitialsLabel(userName: userName)
		} else {
			userImageView.image = UIImage(named: "unknownUser")
			initialsLabel.removeFromSuperview()
			userImageView.backgroundColor = #colorLiteral(red: 0.9488552213, green: 0.9487094283, blue: 0.9693081975, alpha: 1)
		}
	}

	private func createInitialsLabel(userName: String) {
		initialsLabel.text = presenter.createInitials(name: userName)
		initialsLabel.font = Constants.initalsLabelFont
		initialsLabel.textColor = .white
		initialsLabel.textAlignment = .center
		userImageView.addSubview(initialsLabel)
		initialsLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			initialsLabel.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor),
			initialsLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor)
		])
	}

	// Actions
	@objc private func saveBtnTapped() {
		let updatedUser = userEditView.getUpdatedUser()
		presenter.saveBtnTapped(model: EditedProfileModel(name: updatedUser.userName, bio: updatedUser.userBio, avatar: pickedImage))
	}

	@objc private func cancelBtnTapped() {
		presenter.cancelBtnTapped()
	}

	@objc private func makeMainViewFirstResponder() {
		userEditView.resignViewFirstResponder()
	}

	@objc private func createChooseImageAlertVC() {
		let alertVC = UIAlertController.createImagePickerAlertVC(title: "Выберите источник", message: nil, vc: self) { [weak self] sourceType in
			guard let self = self else { return }
			switch sourceType {
			case .camera, .photoLibrary:
				self.imagePicker.sourceType = (sourceType == .camera) ? .camera : .photoLibrary
				self.present(self.imagePicker, animated: true, completion: nil)
			case .networkGallery:
				self.presenter.networkGalleryTapped()
			}
		}
		present(alertVC, animated: true, completion: nil)
	}
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		imagePicker.dismiss(animated: true, completion: nil)
		initialsLabel.text = nil
		guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
		userImageView.image = image
		pickedImage = image
	}
}

// MARK: - IProfileViewInput

extension EditProfileViewController: EditProfileViewInput {
	/// Метод вью для обновления данных на вью
	public func updateUser() {
		loadUser()
	}

	/// Метод вью, замораживающий редактирование полей на окне в момент сохранения данных
	public func freezeUIInteraction() {
		addPhotoBtn.isUserInteractionEnabled = false
		userEditView.isUserInteractionEnabled = false
		makeMainViewFirstResponder()
		activityIndicator.startAnimating()
		saveBtn.removeFromSuperview()
		headerStack.addArrangedSubview(activityIndicator)
	}

	/// Метод вью, размораживающий редактирование полей после сохранения данных
	public func unfreezeUIInteraction() {
		addPhotoBtn.isUserInteractionEnabled = true
		userEditView.isUserInteractionEnabled = true
		activityIndicator.stopAnimating()
		activityIndicator.removeFromSuperview()
		headerStack.addArrangedSubview(saveBtn)
	}

	/// Метод вью, отвечающий за отображение всплывающего окна, которое уведомляет пользователя об успешного сохранении данных
	public func showSuccessAlert() {
		let alertVC = UIAlertController(title: "Success", message: "You are breathtaking", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
			self?.unfreezeUIInteraction()
			self?.presenter.closeBtnTapped()
		}
		alertVC.addAction(okAction)
		self.present(alertVC, animated: true, completion: nil)
	}

	/// Метод вью, отвечающий за отображение всплывающего окна.
	/// Окно уведомляет пользователя об неуспешном сохранении данных и даёт возможность попробовать сохранить данные повторно
	public func showFailureAlert() {
		let failedAlertVC = UIAlertController(title: "Could not save profile", message: "Try again", preferredStyle: .alert)
		let confirmAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
			self?.unfreezeUIInteraction()
			self?.presenter.closeBtnTapped()
		}
		let repeatAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
			self?.saveBtnTapped()
		}
		failedAlertVC.addAction(confirmAction)
		failedAlertVC.addAction(repeatAction)
		self.present(failedAlertVC, animated: true, completion: nil)
	}
	
	/// Метод вью, который обновляет аватарку юзера
	/// - Parameter model: Модель с аватаркой
	public func updateImageView(model: ImageModel) {
		let image = model.image
		userImageView.image = image
		initialsLabel.removeFromSuperview()
		pickedImage = image
	}
}
