//
//  CellProtocols.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 03.03.2023.
//

import Foundation

/// Протокол для переиспользования ячейки tableView
protocol IReusableCell: AnyObject {
	static var identifier: String { get }
}

/// Протокол для конфигурации ячейки tableView
protocol IConfurableViewProtocol {
	associatedtype ConfigurationModel
	func configure(with model: ConfigurationModel)
}
