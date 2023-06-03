//
//  IUserInfoService.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 18.04.2023.
//

import Foundation
import Combine
import UIKit

/// Протокол сервиса для работы с данными об юзере
protocol IUserInfoService: AnyObject {
	func saveUserInfo(queue: DispatchQueue, user: ProfileModel, image: UIImage?) -> AnyPublisher<Void, Error>
	func loadUserInfo(queue: DispatchQueue) -> AnyPublisher<(ProfileModel?, UIImage?), Error>
	func cancelSaving()
}
