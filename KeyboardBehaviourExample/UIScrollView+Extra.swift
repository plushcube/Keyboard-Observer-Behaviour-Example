//
//  UIScrollView+Extra.swift
//  KeyboardBehaviourExample
//
//  Created by Andrey Chevozerov on 17/09/2017.
//  Copyright © 2017 Revolut. All rights reserved.
//

import UIKit

extension UIScrollView {
    var bottomInset: CGFloat {
        get {
            return contentInset.bottom
        }
        set(value) {
            var inset = contentInset
            inset.bottom = value
            contentInset = inset
            scrollIndicatorInsets = inset
        }
    }

    func scrollToBottom(animated: Bool = true) {
        let offset = contentSize.height + contentInset.bottom - frame.height
        setContentOffset(CGPoint(x: 0.0, y: max(offset, 0.0)), animated: true)
    }
}
