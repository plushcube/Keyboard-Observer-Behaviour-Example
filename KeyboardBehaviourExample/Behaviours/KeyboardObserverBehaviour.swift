//
//  KeyboardObserverBehaviour.swift
//  KeyboardBehaviourExample
//
//  Created by Andrey Chevozerov on 22/08/2017.
//  Copyright © 2017 Revolut. All rights reserved.
//

import UIKit

final class KeyboardObserverBehaviour: ViewControllerLifecycleBehaviour {
    typealias KeyboardHeightChangeHandler = (_ height: CGFloat) -> Void

    var beforeAnimation: KeyboardHeightChangeHandler = { _ in }
    var insideAnimation: KeyboardHeightChangeHandler = { _ in }
    var afterAnimation: KeyboardHeightChangeHandler = { _ in }

    func willAppear(_ controller: UIViewController, animated: Bool) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(processNotification),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)
    }

    func didDisappear(_ controller: UIViewController, animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }

    @objc private func processNotification(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }

        let height = UIScreen.main.bounds.height - frame.origin.y

        beforeAnimation(height)

        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve ?? .easeInOut
        let options = UIViewAnimationOptions.init(rawValue: UInt(curve.rawValue))
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: options,
                       animations: { self.insideAnimation(height) },
                       completion: { _ in self.afterAnimation(height) })
    }
}
