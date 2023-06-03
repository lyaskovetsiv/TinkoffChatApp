//
//  UIAlertController.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 02.04.2023.
//

import Foundation
import UIKit

extension UIAlertController {
	/// Метод, который создаёт UIAlertController c ошибкой
	/// - Parameter message: Текст ошибки
	/// - Returns: Экземпляр UIAlertController
	static func createErrorAlertVC(message: String) -> UIAlertController {
		let alertVC = UIAlertController(title: "Упс!", message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default)
		alertVC.addAction(okAction)
		return alertVC
	}

	/// Метод, который создаёт UIAlertController с меню выбора способа установки аватарки
	/// - Parameters:
	///   - title: Заголовок контроллера
	///   - message: Текст контроллера
	///   - vc: Текущий контроллер
	///   - completion: Обработчик
	/// - Returns: Экземпляр UIAlertController
	static func createImagePickerAlertVC(
		title: String?,
		message: String?,
		vc: UIViewController,
		completion: @escaping (_ source: ImagePickerSource) -> Void) -> UIAlertController {
			let alertVC = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
			let cameraAction = UIAlertAction(title: "Сделать фото", style: .default) { _ in
				if UIImagePickerController.isSourceTypeAvailable(.camera) {
					completion(.camera)
				} else {
					// show alert if camera is not available
					let alertController = UIAlertController(title: nil, message: "Камера не доступна", preferredStyle: .alert)
					alertController.addAction(UIAlertAction(title: "OK", style: .default))
					vc.present(alertController, animated: true)
				}
			}
			let galleryAction = UIAlertAction(title: "Выбрать из галереи", style: .default) { _ in
					completion(.photoLibrary)
			}
			let networkAction = UIAlertAction(title: "Загрузить", style: .default) { _ in
				completion(.networkGallery)
			}
			let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
			alertVC.addAction(cameraAction)
			alertVC.addAction(galleryAction)
			alertVC.addAction(networkAction)
			alertVC.addAction(cancelAction)
			return alertVC
	}
}
