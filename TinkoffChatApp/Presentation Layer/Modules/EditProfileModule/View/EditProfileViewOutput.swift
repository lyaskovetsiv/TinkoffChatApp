//
//  EditProfileViewOutput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation
import UIKit

/// Протокол для презентера EditProfile модуля
protocol EditProfileViewOutput {
	func viewDidLoad()
	func closeBtnTapped()
	func cancelBtnTapped()
	func saveBtnTapped(model: EditedProfileModel)
	func createInitials(name: String) -> String
	func viewWillDissapear()
	func getCurrentTheme() -> Theme
	func networkGalleryTapped()
}
