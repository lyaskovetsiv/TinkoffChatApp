//
//  CAGradientLayer+extension.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 03.03.2023.
//

import Foundation
import QuartzCore
import UIKit

/// Константы для метода createGradient(for view: UIView) у CAGradientLayer
private enum Constants {
	static let startGradientColor: UIColor = UIColor(red: 0.95, green: 0.62, blue: 0.71, alpha: 1.00)
	static let finishGradientColor: UIColor = UIColor(red: 0.93, green: 0.48, blue: 0.58, alpha: 1.00)
}

extension CAGradientLayer {
	/// Метод, устанавливающий градиент для втю
	/// - Parameter view: Вью
	static func createGradient(for view: UIView) {
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = [ Constants.startGradientColor.cgColor,
								 Constants.finishGradientColor.cgColor]
		gradientLayer.cornerRadius = view.layer.cornerRadius
		gradientLayer.startPoint = CGPoint(x: 0, y: 0)
		gradientLayer.endPoint = CGPoint(x: 0, y: 1)
		gradientLayer.frame = view.bounds
		view.layer.insertSublayer(gradientLayer, at: 0)
	}
}
