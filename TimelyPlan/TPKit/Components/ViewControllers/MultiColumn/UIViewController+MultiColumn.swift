//
//  UIViewController+MultiColumn.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/11.
//

import Foundation

extension UIViewController {
    
    fileprivate struct Constants {
        static var multiColumnViewControllerKey = "multiColumnViewControllerKey"
    }
    
    /// 多边栏视图控制器
    var multiColumnViewController: TPMultiColumnViewController? {
        get {
            var weakProxy = objc_getAssociatedObject(self, &Constants.multiColumnViewControllerKey)
            if weakProxy == nil, let navigationController = self.navigationController {
                weakProxy = objc_getAssociatedObject(navigationController, &Constants.multiColumnViewControllerKey)
            }
            
            let proxy = weakProxy as? TPWeakProxy<TPMultiColumnViewController>
            return proxy?.target
        }

        set {
            let weakProxy = TPWeakProxy(target: newValue)
            objc_setAssociatedObject(self,
                                   &Constants.multiColumnViewControllerKey,
                                   weakProxy,
                                   .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
