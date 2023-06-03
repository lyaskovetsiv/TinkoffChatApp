//
//  Animator.swift
//  TinkoffChatApp
//
//  Created by Ivan Lyaskovets on 01.05.2023.
//

import Foundation
import UIKit

/// Класс, отвечающий за кастомные переходы
final class Animator: NSObject {
	// MARK: - Private properties

	private let animationDuration: CGFloat
	private let animationType: AnimationType

	// MARK: - Init

	init (duration: CGFloat, type: AnimationType) {
		self.animationDuration = duration
		self.animationType = type
	}
}

// MARK: - Private methods

extension Animator {
	private func presentAnimation(with transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
		viewToAnimate.transform = CGAffineTransform(scaleX: 0, y: 0	)
		let duration = transitionDuration(using: transitionContext)
		UIView.animate(
			withDuration: duration,
			delay: 0,
			usingSpringWithDamping: 0.8,
			initialSpringVelocity: 0.3,
			options: .curveEaseInOut) {
				viewToAnimate.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
			} completion: { _ in
				// Анимация завершена
				transitionContext.completeTransition(true)
			}
	}

	private func dismissAnimation(with transionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
		let duration = transitionDuration(using: transionContext)
		// Анимации для сокрытия модального окна
		let scaleDown = CGAffineTransform(scaleX: 0.3, y: 0.3)
		let moveOut = CGAffineTransform(translationX: -viewToAnimate.frame.width, y: 0)

		UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear) {
			// Уменьшаем окно
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.7) {
				viewToAnimate.transform = scaleDown
			}
			// Уменьшаем окно, уводим влево и делаем невидимым
			UIView.addKeyframe(withRelativeStartTime: 3.0 / duration, relativeDuration: 1.0) {
				viewToAnimate.transform = scaleDown.concatenating(moveOut)
				viewToAnimate.alpha = 0
			}
		} completion: { _ in
			// Удаляем editedProfileView из контейнера
			viewToAnimate.removeFromSuperview()
			// Анимация завершена
			transionContext.completeTransition(true)
		}
	}
}

// MARK: - UIViewControllerAnimatedTransitioning

extension Animator: UIViewControllerAnimatedTransitioning {
	// Метод, возвращающий продолжительность перехода
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return animationDuration
	}

	// Основной метод для создания анимации
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		// Проверяем наши контроллеры
		guard let toViewController = transitionContext.viewController(forKey: .to),
			  let fromViewController = transitionContext.viewController(forKey: .from)
		else {
			// Анимация не завершена
			transitionContext.completeTransition(false)
			return
		}
		switch animationType {
		case .present:
			transitionContext.containerView.addSubview(toViewController.view)
			presentAnimation(with: transitionContext, viewToAnimate: toViewController.view)
		case .dismiss:
			transitionContext.containerView.addSubview(toViewController.view)
			transitionContext.containerView.addSubview(fromViewController.view)
			dismissAnimation(with: transitionContext, viewToAnimate: fromViewController.view)
		}
	}
}

// MARK: - UIViewControllerTransitioningDelegate

extension Animator: UIViewControllerTransitioningDelegate {
	// Откуда берётся анимация для present
	func animationController(
		forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return self
	}

	// Откуда берётся анимация для dismiss
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return self
	}
}
