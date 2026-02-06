//
//  UIViewController+Swizzler.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/24.
//

import Foundation
import UIKit

extension UIViewController {

    static func swizzleUIViewControllerMethods() {
        swizzleInstanceMethod(UIViewController.self,
                              #selector(viewWillLayoutSubviews),
                              #selector(tp_UIViewControllerViewWillLayoutSubviews))
    }
    
    @objc private func tp_UIViewControllerViewWillLayoutSubviews() {
        self.tp_UIViewControllerViewWillLayoutSubviews()
        themeDidChange()
    }
    
}
