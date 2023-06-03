//
//  ChannelsListViewController.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 03.03.2023.
//

import UIKit
import Combine

/// Вью ChannelsList  модуля
final class ChannelsListViewController: UIViewController {
	// MARK: - Public properties
	
	var presenter: ChannelsListViewOutput!
	
	// MARK: - Private constants (UI)
	
	private enum Constants {
		// Sizes
		static let heightForHeaderSection: CGFloat = 52
		static let heightForRow: CGFloat = 76
		static let separatorHeight: CGFloat = 1
		static let emptyCaseImageViewWidth: CGFloat = 120
		static let emptyCaseImageViewHeight: CGFloat = 80
		// Colors
		static let separatorColor: UIColor = #colorLiteral(red: 0.8273360729, green: 0.8273563981, blue: 0.835514605, alpha: 1)
		// Images
		static let noDataCaseImage = UIImage(systemName: "person.3")
		// Constraits
		static let separatorLeadingAnchorConstant: CGFloat = 73
		static let emptyCaseLabelCenterYConstant: CGFloat = 20
	}
	
	// MARK: - UI
	
	lazy private var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.register(ChannelsListCell.self, forCellReuseIdentifier: ChannelsListCell.identifier)
		return tableView
	}()
	
	lazy private var myRefreshControll: UIRefreshControl = {
		let refreshControll = UIRefreshControl()
		refreshControll.addTarget(self, action: #selector(pulledToRefresh(sender:)), for: .valueChanged)
		return refreshControll
	}()
	
	lazy private var activityIndicatior: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
		view.startAnimating()
		return view
	}()
	
	lazy private var emptyCaseLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.text = "No channels yet."
		label.isHidden = true
		return label
	}()
	
	lazy private var emptyCaseImageView: UIImageView = {
		let imageView = UIImageView(image: Constants.noDataCaseImage)
		imageView.contentMode = .scaleAspectFit
		imageView.isHidden = true
		return imageView
	}()

	// MARK: - LifeCycleOfVC

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		presenter.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setDefaultBackgroundColor()
		presenter.viewWillAppear()
	}
}

// MARK: - Private methods

extension ChannelsListViewController {
	private func setupView () {
		title = "Channels"
		setDefaultBackgroundColor()
		tableView.refreshControl = myRefreshControll
		setupNavigation()
		setupTableView()
		view.addSubview(tableView)
		setupConstraits()
	}
	
	private func setupNavigation() {
		let backButtonItem = UIBarButtonItem()
		backButtonItem.title = ""
		navigationItem.backBarButtonItem = backButtonItem
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Channel", style: .plain,
															target: self,
															action: #selector(addNewChannelTapped))
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicatior)
	}
	
	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.dataSource = self
		tableView.delegate = self
	}

	private func setupConstraits() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}

	private func createCustomSeparator() -> UIView {
		let separator = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.5))
		separator.backgroundColor = Constants.separatorColor
		return separator
	}

	@objc private func addNewChannelTapped() {
		let alertVC = UIAlertController(title: "New channel", message: nil, preferredStyle: .alert)
		alertVC.addTextField { textField in
			textField.placeholder = "Channel Name"
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
		let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
			if let text = alertVC.textFields?.first?.text {
				self?.presenter.createBtnTapped(with: text)
			}
		}
		alertVC.addAction(cancelAction)
		alertVC.addAction(createAction)
		self.present(alertVC, animated: true, completion: nil)
	}

	@objc private func pulledToRefresh(sender: UIRefreshControl) {
		presenter.refreshChannels()
		sender.endRefreshing()
	}
}

// MARK: - UITableViewDataSource

extension ChannelsListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		presenter.getNumberOfChannels()
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ChannelsListCell.identifier, for: indexPath) as? ChannelsListCell
		else { return UITableViewCell() }
		let model: ChannelModel = presenter.getChannel(row: indexPath.row)
		cell.configure(with: model)
		return cell
	}
}

// MARK: - UITableViewDelegate

extension ChannelsListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Constants.heightForRow
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return Constants.heightForHeaderSection
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 {
			let separator = createCustomSeparator()
			cell.addSubview(separator)
			separator.translatesAutoresizingMaskIntoConstraints = false
			separator.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: Constants.separatorLeadingAnchorConstant).isActive = true
			separator.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
			separator.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
			separator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight).isActive = true
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		presenter.cellDidTapped(row: indexPath.row)
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
			self?.presenter.deleteChannelTapped(at: indexPath)
		}
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
}

// MARK: - IConversationsListViewInput

extension ChannelsListViewController: ChannelsListViewInput {
	/// Метод, отвечающий за обновление данных на вью
	public func updateData() {
		tableView.isHidden = false
		emptyCaseImageView.removeFromSuperview()
		emptyCaseLabel.removeFromSuperview()
		tableView.reloadData()
	}

	/// Метод, отвечающий за отображение окна с ошибкой
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

	/// Метод-заглушка, который срабатывает в дву случаях - при ошибке извлечения каналов из coreData \ удалении канала,
	/// а также в случае если из coreData возвращается пустой массив с каналами
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
			emptyCaseImageView.bottomAnchor.constraint(equalTo: emptyCaseLabel.topAnchor),
			emptyCaseImageView.widthAnchor.constraint(equalToConstant: Constants.emptyCaseImageViewWidth),
			emptyCaseImageView.heightAnchor.constraint(equalToConstant: Constants.emptyCaseImageViewHeight)
		])
	}
}
