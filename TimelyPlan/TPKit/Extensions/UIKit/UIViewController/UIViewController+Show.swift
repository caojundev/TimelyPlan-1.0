//
//  UIViewController+Show.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/28.
//

import Foundation

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
}
