//
//  ViewController.swift
//  KeyboardBehaviourExample
//
//  Created by Andrey Chevozerov on 17/09/2017.
//  Copyright © 2017 Revolut. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var inputField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let keyboard = KeyboardObserverBehaviour()
        keyboard.beforeAnimation = { height in
            self.scrollView.bottomInset = height
        }
        keyboard.afterAnimation = { _ in
            self.scrollView.scrollToBottom()
        }
        addBehaviour(keyboard)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)

        super.viewWillAppear(animated)
    }

    @IBAction private func continuePressed(_ sender: UIButton?) {
        view.endEditing(true)

        if let name = inputField.text, name.characters.count > 1 {
            let alert = UIAlertController(title: "Use that name?", message: name, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Empty name", message: "You must enter your real name in order to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @objc private func tap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

