//
//  BasicViewController.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 30.04.2023.
//

import UIKit

/// Вьюконтроллер, в котором реализован функционал гербовой анимации
class BasicViewController: UIViewController {
	// MARK: - Public properties

	public var keyboardFrame: CGRect = .zero

	// MARK: - Private properties

	private lazy var herbCell: CAEmitterCell = {
		var cell = CAEmitterCell()
		cell.contents = UIImage(named: "herb")?.cgImage
		cell.birthRate = 13
		cell.lifetime = 0.3
		cell.spin = 1
		cell.velocity = 40
		cell.velocityRange = 40
		cell.scale = 0.3
		cell.scaleRange = 0.1
		cell.emissionLongitude = .pi
		cell.emissionRange = .pi
		cell.alphaSpeed = -2
		return cell
	}()

	private var longPressTimer: Timer?

	private let emitterLayer = CAEmitterLayer()

	// MARK: - LifeCycleOfVC

	override func viewDidLoad() {
		super.viewDidLoad()
		setupEmmiterLayer()
	}

	// MARK: - Touches

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		if let touch = touches.first {
			let touchPoint = touch.location(in: self.view)
			if keyboardFrame.contains(touchPoint) {
				self.emitterLayer.removeAllAnimations()
				self.emitterLayer.removeFromSuperlayer()
			} else {
				view.layer.addSublayer(emitterLayer)
				emitterLayer.emitterPosition = touch.location(in: view)
				emitterLayer.opacity = 1
			}
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		if let touch = touches.first {
			let touchPoint = touch.location(in: self.view)
			if keyboardFrame.contains(touchPoint) {
				CATransaction.begin()
				CATransaction.setAnimationDuration(0.5)
				self.emitterLayer.opacity = 0
				CATransaction.commit()
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
					self?.emitterLayer.removeAllAnimations()
					self?.emitterLayer.removeFromSuperlayer()
				}
			} else {
				if let layers = view.layer.sublayers, !layers.contains(where: { $0 is CAEmitterLayer }) {
					emitterLayer.opacity = 1
					view.layer.addSublayer(emitterLayer)
				}
				emitterLayer.emitterPosition = touch.location(in: view)
			}
		}
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		self.emitterLayer.removeAllAnimations()
		self.emitterLayer.removeFromSuperlayer()
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		self.emitterLayer.removeAllAnimations()
		self.emitterLayer.removeFromSuperlayer()
	}
}

// MARK: - Private methods

extension BasicViewController {
	private func setupEmmiterLayer() {
		emitterLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
		emitterLayer.emitterSize = CGSize(width: 10, height: 10)
		emitterLayer.renderMode = .unordered
		emitterLayer.emitterCells = [herbCell]
	}
}
