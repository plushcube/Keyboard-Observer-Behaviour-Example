//
//  ViewControllerLifecycleBehaviour.swift
//  KeyboardBehaviourExample
//
//  Created by Andrey Chevozerov on 01/08/2017.
//  Copyright © 2017 Revolut. All rights reserved.
//
//  See: http://irace.me/lifecycle-behaviours

import UIKit

protocol BehaviourTarget {
    func addBehaviour(_ behaviour: ViewControllerLifecycleBehaviour)
    func addBehaviours(_ behaviours: [ViewControllerLifecycleBehaviour])
    func behaviour<T>(of type: T.Type) -> T?
}

protocol ViewControllerLifecycleBehaviour {
    func didLoad(_ controller: UIViewController)
    func willAppear(_ controller: UIViewController, animated: Bool)
    func didAppear(_ controller: UIViewController, animated: Bool)
    func willDisappear(_ controller: UIViewController, animated: Bool)
    func didDisappear(_ controller: UIViewController, animated: Bool)
    func willLayout(_ controller: UIViewController)
    func didLayout(_ controller: UIViewController)
}

extension ViewControllerLifecycleBehaviour {
    func didLoad(_ controller: UIViewController) {}
    func willAppear(_ controller: UIViewController, animated: Bool) {}
    func didAppear(_ controller: UIViewController, animated: Bool) {}
    func willDisappear(_ controller: UIViewController, animated: Bool) {}
    func didDisappear(_ controller: UIViewController, animated: Bool) {}
    func willLayout(_ controller: UIViewController) {}
    func didLayout(_ controller: UIViewController) {}
}

extension UIViewController: BehaviourTarget {
    func addBehaviour(_ behaviour: ViewControllerLifecycleBehaviour) {
        addBehaviours([ behaviour ])
    }

    func addBehaviours(_ behaviours: [ViewControllerLifecycleBehaviour]) {
        if let container = behavioursContainer {
            container.appendBehaviours(behaviours)
        } else {
            let container = LifecycleBehaviourViewController()
            container.appendBehaviours(behaviours)

            addChildViewController(container)
            view.addSubview(container.view)
            container.didMove(toParentViewController: self)
        }
    }

    func behaviour<T>(of type: T.Type) -> T? {
        guard let container = behavioursContainer else { return nil }
        return container.internalBehaviours.first(where: { type(of: $0) == type }) as? T
    }

    // MARK: - Private

    private var behavioursContainer: LifecycleBehaviourViewController? {
        return childViewControllers.first(where: { $0 is LifecycleBehaviourViewController }) as? LifecycleBehaviourViewController
    }
}

fileprivate final class LifecycleBehaviourViewController: UIViewController {
    fileprivate var internalBehaviours: [ViewControllerLifecycleBehaviour] = []

    func appendBehaviours(_ behaviours: [ViewControllerLifecycleBehaviour]) {
        internalBehaviours.enumerated().forEach { index, behaviour in
            let type = type(of: behaviour)
            if behaviours.contains(where: { type(of: $0) == type }) {
                internalBehaviours.remove(at: index)
            }
        }
        internalBehaviours.append(contentsOf: behaviours)

        applyBehaviours(behaviours) { behaviour, controller in
            behaviour.didLoad(controller)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isHidden = true

        applyBehaviours(internalBehaviours) { behaviour, controller in
            behaviour.didLoad(controller)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applyBehaviours(internalBehaviours) { behaviour, controller in
            behaviour.willAppear(controller, animated: animated)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        applyBehaviours(internalBehaviours) { behaviour, controller in
            behaviour.didAppear(controller, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        applyBehaviours(internalBehaviours) { behaviour, controller in
            behaviour.willDisappear(controller, animated: animated)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        applyBehaviours(internalBehaviours) { behaviour, controller in
            behaviour.didDisappear(controller, animated: animated)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        applyBehaviours(internalBehaviours) { behaviour, controller in
            behaviour.willLayout(controller)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        applyBehaviours(internalBehaviours) { behaviour, controller in
            behaviour.didLayout(controller)
        }
    }

    // MARK: - Private

    typealias BehaviourBody = (_ behaviour: ViewControllerLifecycleBehaviour, _ controller: UIViewController) -> Void

    private func applyBehaviours(_ behaviours: [ViewControllerLifecycleBehaviour], handler: BehaviourBody) {
        guard let parent = parent else { return }
        behaviours.forEach({ handler($0, parent) })
    }
}
