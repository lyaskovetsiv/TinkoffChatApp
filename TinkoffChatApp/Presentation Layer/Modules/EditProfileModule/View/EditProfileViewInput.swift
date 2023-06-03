//
//  EditProfileViewInput.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 16.04.2023.
//

import Foundation
import UIKit

/// Протокол для вью EditProfile модуля
protocol EditProfileViewInput: AnyObject {
	func updateUser()
	func freezeUIInteraction()
	func unfreezeUIInteraction()
	func showSuccessAlert()
	func showFailureAlert()
	func updateImageView(model: ImageModel)
}
