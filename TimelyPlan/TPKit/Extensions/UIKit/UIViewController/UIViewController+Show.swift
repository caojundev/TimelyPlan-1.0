//
//  UIViewController+Show.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/28.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// 作为导航栏的根视图控制器从顶层弹出
    func showAsNavigationRoot(style: UIModalPresentationStyle = .formSheet,
                              animated: Bool = true,
                              completion: (() -> Void)? = nil) {
        let navController = UINavigationController(rootViewController: self)
        navController.modalPresentationStyle = style
        navController.show(animated: animated, completion: completion)
    }
    
    func popoverShowAsNavigationRoot(animated: Bool = true,
                              completion: (() -> Void)? = nil) {
        let navController = UINavigationController(rootViewController: self)
        navController.popoverShow()
    }
    
    /// 从顶层弹出视图控制器
    @objc func show(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let topVC = UIViewController.topPresented else {
            return
        }
        
        if topVC.isBeingDismissed {
            return
        }
        
        topVC.present(self, animated: animated, completion: completion)
    }
    
    /// 关闭当前视图控制器
    /// - Note: 当前视图控制器上可能弹出了多层视图控制器，此时直接调用 `dismiss` 只会关闭最上层的弹出视图控制器，
    ///         导致当前视图控制器无法关闭；此方法自最顶层开始逐层关闭（无动画），最后关闭当前视图控制器。
    /// - Parameters:
    ///   - animated: 关闭当前视图控制器是否使用动画
    ///   - completion: 关闭当前视图控制器后的回调
    func dismissAll(animated: Bool = false, completion: (() -> Void)? = nil) {
        /// 收集当前视图控制器之上弹出的所有视图控制器（自下而上）
        var presentedViewControllers: [UIViewController] = []
        var viewController = presentedViewController
        while let presented = viewController {
            presentedViewControllers.append(presented)
            viewController = presented.presentedViewController
        }
        
        /// 自最顶层开始逐层关闭
        for presented in presentedViewControllers.reversed() {
            presented.dismiss(animated: false, completion: nil)
        }
        
        /// 最后关闭当前视图控制器
        dismiss(animated: animated, completion: completion)
    }
}
