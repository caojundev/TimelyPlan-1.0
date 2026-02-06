//
//  UIView+Idenfifier.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/14.
//

import Foundation
import UIKit

extension UIView {
    
    private struct AssociatedKeys {
        static var identifier = "identifier"
    }
    
    // MARK: - Identifier
    var identifier: String? {
        get {
            return associated.get(&AssociatedKeys.identifier)
        }
        set {
            associated.set(retain: &AssociatedKeys.identifier, newValue)
        }
    }
    
    /// 根据标识获取子视图
    func viewWithIdentifier(_ identifier: String) -> UIView? {
        for subview in subviews {
            if subview.identifier == identifier {
                return subview
            }
        }
        
        return nil
    }
    
    
}
