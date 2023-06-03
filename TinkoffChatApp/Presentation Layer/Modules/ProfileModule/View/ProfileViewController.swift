//
//  ProfileViewController.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 03.04.2023.
//

import UIKit
import Combine

/// Вью Profile модуля
final class ProfileViewController: BasicViewController {
	// MARK: - Public properties

	var presenter: ProfileViewOutput!

	// MARK: - Private constants (UI)

	private enum Constants {
		// Sizes
		static let userImageViewHeight: CGFloat = 128
		static let userImageViewWidth: CGFloat = 128
		static let unknownImageViewHeight: CGFloat = 70
		static let unknownImageViewWidth: CGFloat = 70
		static let userInfoViewHeight: CGFloat = 88
		static let mainViewHeight: CGFloat = 402
		static let editBtnHeight: CGFloat = 50
		// Colors
		static let userInfoLabelTextColor = #colorLiteral(red: 0.5410659909, green: 0.5409145951, blue: 0.5574275851, alpha: 1)
		static let lightBackgroundColor = #colorLiteral(red: 0.9488552213, green: 0.9487094283, blue: 0.9693081975, alpha: 1)
		static let unknownImageColor = #colorLiteral(red: 0.533272922, green: 0.5333681703, blue: 0.5332669616, alpha: 1)
		// Images
		static let unknownUserImage: UIImage? = UIImage(systemName: "person.fill")?.withTintColor(unknownImageColor, renderingMode: .alwaysOriginal)
		// Fonts & Text sizes
		static let standartFontSize: CGFloat = 17
		static let enlargedFontSize: CGFloat = 22
		static let initalsLabelFont: UIFont = FontKit.roundedFont(ofSize: 60, weight: .regular)
		// Constraits
		static let headerStackTrailingAnchorConstant: CGFloat = -16
		static let headerStackLeadingAnchorConstant: CGFloat = 16
		static let editBtnLeadingTrailingConstant: CGFloat = 16
		static let editTopConstant: CGFloat = 24
		static let userImageViewTopAnchorConstant: CGFloat = 32
		static let addPhotoBtnTopAnchorConstant: CGFloat = 24
		static let userInfoStackTopAnchorConstant: CGFloat = 24
		static let userInfoViewTopAnchorConstant: CGFloat = 24
		static let mainViewTopAnchorConstant: CGFloat = 149
		static let mainViewTrailingLeadingConstant: CGFloat = 16
		static let userInfoStackTrailingLeadingConstant: CGFloat = 16
	}
	private enum State {
		case loading
		case loaded(ProfileModel?, UIImage?)
	}
	private var state: State = .loading {
		didSet {
			switch state {
			case .loading:
				break
			case .loaded(let profile, let image):
				configureView(profile: profile, image: image)
			}
		}
	}
	private var loadPublisher: AnyPublisher<(ProfileModel?, UIImage?), Error>
	private var dataRequest: Cancellable?
	private var inEditingMode: Bool = false

	// MARK: - UI

	lazy private var mainView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 10
		return view
	}()

	lazy private var userImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFill
		imageView.accessibilityIdentifier = "userImageView"
		imageView.layer.cornerRadius = Constants.userImageViewHeight / 2
		return imageView
	}()

	lazy private var addPhotoBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.titleLabel?.font = .systemFont(ofSize: Constants.standartFontSize, weight: .regular)
		btn.setTitle("Add Photo", for: .normal)
		btn.addTarget(self, action: #selector(createChooseImageAlertVC), for: .touchUpInside)
		btn.accessibilityIdentifier = "addPhotoBtn"
		return btn
	}()

	lazy private var userNameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: Constants.enlargedFontSize, weight: .bold)
		label.textAlignment = .center
		label.accessibilityIdentifier = "userNameLabel"
		return label
	}()

	lazy private var userBioLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.textAlignment = .center
		label.textColor = Constants.userInfoLabelTextColor
		label.font = .systemFont(ofSize: Constants.standartFontSize, weight: .regular)
		return label
	}()

	lazy private var userInfoStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [userNameLabel, userBioLabel])
		stackView.axis = .vertical
		stackView.spacing = 10
		stackView.distribution = .equalSpacing
		return stackView
	}()

	lazy private var editBtn: UIButton = {
		let btn = UIButton()
		btn.setTitle("Edit Profile", for: .normal)
		btn.addTarget(self, action: #selector(editBtnTapped), for: .touchUpInside)
		btn.layer.cornerRadius = 14
		btn.backgroundColor = .systemBlue
		return btn
	}()

	lazy private var initialsLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.font = Constants.initalsLabelFont
		label.textAlignment = .center
		return label
	}()

	lazy private var unknownImageView: UIImageView = {
		let imageView = UIImageView(image: Constants.unknownUserImage)
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	private var imagePicker: UIImagePickerController!
	
	private var userDataRequest: Cancellable?

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
		view.backgroundColor = presenter.getCurrentTheme() == .light ? Constants.lightBackgroundColor : .black
		mainView.backgroundColor = presenter.getCurrentTheme() == .light ? .white : .darkGray
		presenter.viewDidLoad()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if userImageView.image == nil && !unknownImageView.isDescendant(of: view) {
			CAGradientLayer.createGradient(for: userImageView)
		} else {
			userImageView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
		}
	}
}

// MARK: - Private methods

extension ProfileViewController {
	private func setupView() {
		title = "My profile"
		navigationItem.largeTitleDisplayMode = .always
		setDefaultBackgroundColor()
		setupImageController()
		setupGestures()
		view.addSubview(mainView)
		mainView.addSubview(userImageView)
		mainView.addSubview(addPhotoBtn)
		mainView.addSubview(userInfoStack)
		mainView.addSubview(editBtn)
		setupConstraits()
	}

	private func setupImageController () {
		imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
	}

	private func setupGestures() {
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(editBtnLongTapped))
		editBtn.addGestureRecognizer(longPressGesture)
	}

	private func setupConstraits() {
		mainView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			mainView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.mainViewTopAnchorConstant),
			mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.mainViewTrailingLeadingConstant),
			mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.mainViewTrailingLeadingConstant),
			mainView.heightAnchor.constraint(equalToConstant: Constants.mainViewHeight)
		])

		userImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			userImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: Constants.userImageViewTopAnchorConstant),
			userImageView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
			userImageView.widthAnchor.constraint(equalToConstant: Constants.userImageViewWidth),
			userImageView.heightAnchor.constraint(equalToConstant: Constants.userImageViewHeight)
		])

		addPhotoBtn.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			addPhotoBtn.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
			addPhotoBtn.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: Constants.addPhotoBtnTopAnchorConstant)
		])

		userInfoStack.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			userInfoStack.topAnchor.constraint(equalTo: addPhotoBtn.bottomAnchor, constant: Constants.userInfoStackTopAnchorConstant),
			userInfoStack.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
			userInfoStack.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: Constants.userInfoStackTrailingLeadingConstant),
			userInfoStack.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -Constants.userInfoStackTrailingLeadingConstant)
		])

		editBtn.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			editBtn.topAnchor.constraint(equalTo: userInfoStack.bottomAnchor, constant: Constants.editTopConstant),
			editBtn.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: Constants.editBtnLeadingTrailingConstant),
			editBtn.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -Constants.editBtnLeadingTrailingConstant),
			editBtn.heightAnchor.constraint(equalToConstant: Constants.editBtnHeight),
			editBtn.centerXAnchor.constraint(equalTo: mainView.centerXAnchor)
		])
	}

	private func loadUser() {
		state = .loading
		dataRequest = loadPublisher
			.subscribe(on: DispatchQueue.global(qos: .background), options: nil)
			.receive(on: DispatchQueue.main, options: nil)
			.catch({ _ in Just(( nil, nil)) })
					.map { result in State.loaded(result.0, result.1) }
			.assign(to: \.state, on: self)
	}

	private func configureView(profile: ProfileModel?, image: UIImage?) {
		setupUserNameLabel(userName: profile?.userName)
		setupBioLabel(userBio: profile?.userBio)
		if let image {
			setupImageView(with: image)
		} else {
			if let userName = profile?.userName, userName.trimmingCharacters(in: .whitespaces) != "" {
				setupInitialLabel(userName: userName)
			} else {
				setupUnknownImage()
			}
		}
	}

	private func setupUserNameLabel(userName: String?) {
		if userName == nil || userName?.trimmingCharacters(in: .whitespaces) == "" {
			userNameLabel.text = "No name"
		} else {
			userNameLabel.text = userName
		}
	}

	private func setupBioLabel(userBio: String?) {
		if userBio == nil || userBio?.trimmingCharacters(in: .whitespaces) == "" {
			userBioLabel.text = "No bio specified"
		} else {
			userBioLabel.text = userBio
		}
	}

	private func setupImageView(with image: UIImage?) {
		initialsLabel.removeFromSuperview()
		unknownImageView.removeFromSuperview()
		userImageView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
		userImageView.image = image
	}

	private func setupInitialLabel(userName: String) {
		userImageView.image = nil
		unknownImageView.removeFromSuperview()
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

	private func setupUnknownImage() {
		userImageView.image = nil
		initialsLabel.removeFromSuperview()
		userImageView.backgroundColor = #colorLiteral(red: 0.9488552213, green: 0.9487094283, blue: 0.9693081975, alpha: 1)
		unknownImageView.center = userImageView.center
		userImageView.addSubview(unknownImageView)
		unknownImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			unknownImageView.heightAnchor.constraint(equalToConstant: Constants.unknownImageViewHeight),
			unknownImageView.widthAnchor.constraint(equalToConstant: Constants.unknownImageViewWidth),
			unknownImageView.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor),
			unknownImageView.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor)
		])
	}

	private func presenterImagePicked(image: UIImage?) {
		var model = EditedProfileModel()
		model.name = userNameLabel.text ?? ""
		model.bio = userBioLabel.text ?? ""
		model.avatar = image
		presenter.saveChanges(model: model)
	}

	// Single EditBtn Tap
	@objc private func editBtnTapped() {
		presenter.editBtnTapped()
	}

	// Long EditBtn Tap
	@objc private func editBtnLongTapped(_ gestureRecognizer: UILongPressGestureRecognizer) {
		if gestureRecognizer.state == .began {
			inEditingMode.toggle()
			if inEditingMode {
				startEditBtnAnimating()
			}
		}
		if gestureRecognizer.state == .ended {
			if !inEditingMode {
				stopEditBtnAnimating()
			}
		}
	}

	// Animating Edit Button
	private func startEditBtnAnimating() {
		// Устанавливаем значения анимации
		let shakeDuration = 0.3
		let shakeAngle: CGFloat = (.pi * 18) / 180
		let shakeX = 5.0
		let shakeY = 5.0
		// Создаём анимацию
		let shakeAnimation = CAKeyframeAnimation(keyPath: "transform")
		shakeAnimation.duration = shakeDuration
		shakeAnimation.repeatCount = .infinity
		shakeAnimation.values = [
			NSValue(caTransform3D: CATransform3DMakeTranslation(-shakeX, -shakeY, 0)),
			NSValue(caTransform3D: CATransform3DMakeRotation(-shakeAngle, 0.0, 0.0, 1.0)),
			NSValue(caTransform3D: CATransform3DMakeTranslation(shakeX, shakeY, 0)),
			NSValue(caTransform3D: CATransform3DMakeRotation(shakeAngle, 0.0, 0.0, 1.0)),
			NSValue(caTransform3D: CATransform3DMakeTranslation(-shakeX, -shakeY, 0))
		]
		shakeAnimation.keyTimes = [
			0.0, 0.25, 0.5, 0.75, 1.0
		]
		// Добавляем анимацию на кнопку
		editBtn.layer.add(shakeAnimation, forKey: "shake")
	}
	
	private func stopEditBtnAnimating() {
		if let presentationLayer = self.editBtn.layer.presentation() {
			// Получаем текущее состояние кнопки из ее presentation layer
			let currentTransform = presentationLayer.transform
			// Устанавливаем это состояние для слоя кнопки
			self.editBtn.layer.transform = currentTransform
		}
		// Удалили анимацию
		self.editBtn.layer.removeAnimation(forKey: "shake")
		// Вернули кнопку в исходное положение
		let returnAnimation = CABasicAnimation(keyPath: "transform")
		returnAnimation.duration = 0.3
		returnAnimation.fromValue = self.editBtn.layer.transform
		returnAnimation.toValue = CATransform3DIdentity
		self.editBtn.layer.add(returnAnimation, forKey: "returnToNormal")
		self.editBtn.layer.transform = CATransform3DIdentity
	}

	// CreatingAlertPhotoPicker
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		imagePicker.dismiss(animated: true, completion: nil)
		guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
		userImageView.image = image
		presenterImagePicked(image: image)
	}
}

// MARK: - IProfileViewInput

extension ProfileViewController: ProfileViewInput {
	/// Метод вью, отвечающий за полное обновление юзера
	public func updateUser() {
		loadUser()
	}
	
	/// Метод вью, который отдаёт текущие значения текстовых полей имени и бил юзера
	public func getUser() -> ProfileModel {
		ProfileModel(userName: userNameLabel.text ?? "", userBio: userBioLabel.text ?? "")
	}

	/// Метод вью, который обновляет аватарку юзера
	/// - Parameter model: Модель с аватаркой
	public func updateImageView(model: ImageModel) {
		userImageView.image = model.image
	}
}
