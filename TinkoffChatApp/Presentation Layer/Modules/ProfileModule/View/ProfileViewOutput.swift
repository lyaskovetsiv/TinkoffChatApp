//
//  ProfileViewOutput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation

/// Протокол для презентера Profile модуля
protocol ProfileViewOutput {
	func viewDidLoad()
	func editBtnTapped()
	func createInitials(name: String) -> String
	func getCurrentTheme() -> Theme
	func networkGalleryTapped()
	func saveChanges(model: EditedProfileModel)
}
