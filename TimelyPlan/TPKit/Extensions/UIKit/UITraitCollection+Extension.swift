//
//  UITraitCollection+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/4.
//

import Foundation
import UIKit

extension UITraitCollection {
    
    /// 通过当前窗口根视图控制器获取当前特征集合
    static var tf_current: UITraitCollection {
        let traitCollection: UITraitCollection
        if let viewController = UIWindow.keyWindow?.rootViewController {
            traitCollection = viewController.traitCollection
        } else {
            traitCollection = UITraitCollection.current
        }
        
        return traitCollection
    }
        
    /// 当前是否为紧凑模式
    class func isCompactMode() -> Bool {
        let traitCollection = UITraitCollection.tf_current
        return traitCollection.horizontalSizeClass == .compact
    }

    /// 当前是否为常规模式
    class func isRegularMode() -> Bool {
        let traitCollection = UITraitCollection.tf_current
        return traitCollection.horizontalSizeClass == .regular
    }
}
