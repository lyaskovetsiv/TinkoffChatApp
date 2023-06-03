//
//  ChannelViewController.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 03.03.2023.
//

import UIKit

/// Вью Channel модуля
final class ChannelViewController: UIViewController {
	// MARK: - Public properties

	var presenter: ChannelViewOutput!

	// MARK: - Private constants (UI)

	private enum Constants {
		// Sizes
		static let heightForHeaderInSection: CGFloat = 10
		static let userImageViewWidth: CGFloat = 30
		static let userImageViewHeight: CGFloat = 30
		static let textFieldHeight: CGFloat = 36
		static let imageViewCornerRadius: CGFloat = 16
		static let userNameWidth: CGFloat = 150
		static let emptyCaseImageViewWidth: CGFloat = 120
		static let emptyCaseImageViewHeight: CGFloat = 80
		// Colors
		static let dateLabelTextColor = #colorLiteral(red: 0.5410659909, green: 0.5409145951, blue: 0.5574275851, alpha: 1)
		static let userImageViewBackgroundColor = #colorLiteral(red: 0.9292986393, green: 0.9293968678, blue: 0.9333828092, alpha: 1)
		static let initialsLabelTextColor = #colorLiteral(red: 0.5410659909, green: 0.5409145951, blue: 0.5574275851, alpha: 1)
		// Images
		static let defaultChannelImage = UIImage(systemName: "message.circle")
		static let noDataCaseImage = UIImage(systemName: "message.and.waveform")
		static let photoImage = UIImage(systemName: "camera")
		// Fonts
		static let dateLabelFont = UIFont.boldSystemFont(ofSize: 11)
		static let userNameLabelFont: UIFont = .systemFont(ofSize: 9)
		static let initialsLabelFont = FontKit.roundedFont(ofSize: 12, weight: .regular)
		// Constraits
		static let tableViewBottomAnchorConstant: CGFloat = -8
		static let textFieldLeadingAnchorConstant: CGFloat = 8
		static let photoImageLeadingAnchorConstant: CGFloat = 8
		static let textFieldBottomAnchorConstant: CGFloat = -8
		static let textFieldTrailingAnchorConstant: CGFloat = -8
		static let emptyCaseLabelCenterYConstant: CGFloat = 20
		static let emptyCaseImageViewBottomAnchorConstant: CGFloat = -14
	}

	// MARK: - UI

	lazy private var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		if #available(iOS 15.0, *) {
			tableView.sectionHeaderTopPadding = 4
		}
		tableView.separatorStyle = .none
		return tableView
	}()

	lazy private var textField: MessageInputTextField = {
		let textField = MessageInputTextField(frame: .zero)
		textField.attributedPlaceholder = NSAttributedString.createAttributedStringForTextField(string: "Type message")
		return textField
	}()
	
	lazy private var activityIndicatior: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
		view.startAnimating()
		return view
	}()
	
	lazy private var emptyCaseLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.text = "No messages yet."
		label.isHidden = true
		return label
	}()
	
	lazy private var photoImageView: UIImageView = {
		let imageView = UIImageView(image: Constants.photoImage)
		imageView.isUserInteractionEnabled = true
		return imageView
	}()
	
	lazy private var emptyCaseImageView: UIImageView = {
		let imageView = UIImageView(image: Constants.noDataCaseImage)
		imageView.contentMode = .scaleAspectFit
		imageView.isHidden = true
		return imageView
	}()

	// MARK: - Private properties

	private var bottomConstrait: NSLayoutConstraint?
	private var keyBoardIsShown: Bool = false

	// MARK: - LifeCicleOfVC

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupObservers()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setDefaultBackgroundColor()
		presenter.viewWillAppear()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - Private methods

extension ChannelViewController {
	private func setupObservers() {
		NotificationCenter.default.addObserver(self,
											   selector: #selector(keyboardWillShow),
											   name: UIResponder.keyboardWillShowNotification,
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(keyboardWillHide),
											   name: UIResponder.keyboardWillHideNotification,
											   object: nil)
	}
	
	private func setupView() {
		setDefaultBackgroundColor()
		navigationItem.largeTitleDisplayMode = .never
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatior)

		tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.identifier)
		tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
		tableView.dataSource = self
		tableView.delegate = self

		view.addSubview(tableView)
		view.addSubview(photoImageView)
		view.addSubview(textField)

		setupGestures()
		setupConstraits()
		textField.buttonTappedAction = { [weak self] in
			self?.presenter.sendMessage(text: self?.textField.text)
			self?.textField.text = nil
		}
	}

	private func setupConstraits() {
		bottomConstrait = textField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.tableViewBottomAnchorConstant)
		bottomConstrait?.isActive = true
		
		photoImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			photoImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.photoImageLeadingAnchorConstant),
			photoImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor)
		])

		textField.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			textField.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: Constants.textFieldLeadingAnchorConstant),
			textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.textFieldTrailingAnchorConstant),
			textField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
		])

		tableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: Constants.tableViewBottomAnchorConstant)
		])
	}
	
	private func setupGestures() {
		let photoViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(photoImageTapped))
		photoImageView.addGestureRecognizer(photoViewTapGesture)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tapGesture)
	}
	
	private func loadImageFor(cell: UITableViewCell) {
		if let indexPath = tableView.indexPath(for: cell),
			let imageCell = cell as? ImageTableViewCell {
			let model = presenter.getMessage(indexPath: indexPath)
			presenter.getImage(url: model.message.text) { model in
				if let model = model {
					DispatchQueue.main.async {
						imageCell.updateImage(model: model)
					}
				}
			}
		}
	}
}

// MARK: - Keyboard

extension ChannelViewController {
	@objc private func keyboardWillShow(notification: NSNotification) {
		if !keyBoardIsShown {
			keyBoardIsShown = true
			guard let userInfo = notification.userInfo,
				  let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
				  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
			// keyboardFrame = keyboardSize
			UIView.animate(withDuration: duration) {
				self.bottomConstrait?.constant = -keyboardSize.height + self.view.safeAreaInsets.bottom - 8
				self.view.layoutIfNeeded()
				if self.tableView.numberOfSections > 0 {
					let lastSectionIndex = self.tableView.numberOfSections - 1
					let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: lastSectionIndex) - 1, section: lastSectionIndex)
					self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
				}
			}
		}
	}

	@objc private func keyboardWillHide(notification: NSNotification) {
		if keyBoardIsShown {
			keyBoardIsShown = false
			guard let userInfo = notification.userInfo,
				  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
			// keyboardFrame = .zero
			UIView.animate(withDuration: duration) {
				self.bottomConstrait?.constant = -8
				self.view.layoutIfNeeded()
			}
		}
	}

	@objc private func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@objc private func photoImageTapped() {
		presenter.photoImageTapped()
	}
}

// MARK: - UITableViewDataSource

extension ChannelViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return presenter.getNumberOfSections()
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return presenter.getTitleForSection(index: section)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return presenter.getNumberOfRows(in: section)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = presenter.getMessage(indexPath: indexPath)
		if !model.hasImage {
			// Если модель не может иметь картинки, то загружаем messageCell
			guard let messageCell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as? MessageTableViewCell
			else { return UITableViewCell()}
			messageCell.configure(with: (message: model.message, isRepeated: model.isRepeated, isLast: model.isLast), userID: presenter.getUserID())
			return messageCell
		} else {
			// Если модель может иметь картинку, то загружаем imageCell
			guard let imageCell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as? ImageTableViewCell
			else { return UITableViewCell()}
			imageCell.configure(with: (message: model.message, isRepeated: model.isRepeated, isLast: model.isLast), userID: presenter.getUserID())
			return imageCell
		}
	}
}

// MARK: - UITableViewDelegate

extension ChannelViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView()

		let dateLabel: UILabel = {
			let label = UILabel()
			label.text = self.tableView(tableView, titleForHeaderInSection: section)
			label.font = Constants.dateLabelFont
			label.textColor = Constants.dateLabelTextColor
			return label
		}()

		headerView.addSubview(dateLabel)
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			dateLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
			dateLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
			dateLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
			dateLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
		])
		return headerView
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return Constants.heightForHeaderInSection
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		loadImageFor(cell: cell)
	}
}

// MARK: - IConversationViewInput

extension ChannelViewController: ChannelViewInput {
	/// Метод, создающий вью с пользовательскими данными для navigationBar
	/// - Parameters:
	///   - name: Имя пользователя
	///   - image: Аватар пользователя
	public func createHeaderUserView(name: String, image: UIImage?) {
		let userView = UIView()
		let userImageView = UIImageView()
		userImageView.contentMode = .scaleAspectFill
		userImageView.clipsToBounds = true
		userImageView.layer.cornerRadius = Constants.imageViewCornerRadius
		userImageView.image = image ?? Constants.defaultChannelImage
		userView.addSubview(userImageView)

		let userNameLabel = UILabel()
		userNameLabel.text = name
		userNameLabel.textAlignment = .center
		userNameLabel.numberOfLines = 1
		userNameLabel.font = Constants.userNameLabelFont
		userView.addSubview(userNameLabel)

		userImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			userImageView.topAnchor.constraint(equalTo: userView.topAnchor),
			userImageView.centerXAnchor.constraint(equalTo: userView.centerXAnchor),
			userImageView.widthAnchor.constraint(equalToConstant: Constants.userImageViewWidth),
			userImageView.heightAnchor.constraint(equalToConstant: Constants.userImageViewHeight)
		])

		userNameLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			userNameLabel.centerXAnchor.constraint(equalTo: userView.centerXAnchor),
			userNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor),
			userNameLabel.bottomAnchor.constraint(equalTo: userView.bottomAnchor),
			userNameLabel.widthAnchor.constraint(equalToConstant: Constants.userNameWidth)
		])
		navigationItem.titleView = userView
	}

	/// Метод, обновляющий данные на контроллере с прокруткой таблицы
	/// - Parameter indexPath: Индекс последнего сообщения
	public func updateDataWithScroll(indexPath: IndexPath?) {
		tableView.isHidden = false
		emptyCaseImageView.removeFromSuperview()
		emptyCaseLabel.removeFromSuperview()
		tableView.reloadData()
		if let indexPath = indexPath {
			tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
		}
	}

	/// Метод, создающий алерты с ошибками
	/// - Parameter message: Текст ошибки
	public func showChannelAlert(message: String) {
		let alertVC = UIAlertController.createErrorAlertVC(message: message)
		present(alertVC, animated: true)
	}

	/// Метод, скрывающий индикатор загрузки с navigationBar
	public func hideActivityIndicator() {
		activityIndicatior.stopAnimating()
		activityIndicatior.isHidden = true
	}

	/// Метод-заглушка, который срабатывает в двух случаях - при ошибке извлечения сообщений из coreData,
	/// а также в случае если из coreData возвращается пустой массив с сообщениями
	public func showNoDataCase() {
		tableView.isHidden = true
		emptyCaseLabel.isHidden = false
		emptyCaseImageView.isHidden = false

		view.addSubview(emptyCaseLabel)
		view.addSubview(emptyCaseImageView)
		emptyCaseLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			emptyCaseLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyCaseLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: Constants.emptyCaseLabelCenterYConstant)
		])

		emptyCaseImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			emptyCaseImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyCaseImageView.bottomAnchor.constraint(equalTo: emptyCaseLabel.topAnchor, constant: Constants.emptyCaseImageViewBottomAnchorConstant),
			emptyCaseImageView.widthAnchor.constraint(equalToConstant: Constants.emptyCaseImageViewWidth),
			emptyCaseImageView.heightAnchor.constraint(equalToConstant: Constants.emptyCaseImageViewHeight)
		])
	}
}

// MARK: - UIScrollViewDelegate

extension ChannelViewController: UIScrollViewDelegate {
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		for cell in tableView.visibleCells {
			loadImageFor(cell: cell)
		}
	}
}
