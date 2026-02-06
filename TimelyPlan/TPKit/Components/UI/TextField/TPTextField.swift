//
//  TPTextField.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/9.
//

import Foundation
import UIKit

class TPTextField: UITextField {
    
    var isActionMenuEnabled: Bool = true
    
    /// 左端视图偏移
    var leftViewOffset: CGPoint = .zero
    
    /// 内容内间距
    var contentInsets: UIEdgeInsets = .zero

    ///清除按钮偏移
    var clearButtonOffset: CGPoint = .zero
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += self.leftViewOffset.x
        rect.origin.y += self.leftViewOffset.y
        return rect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: self.contentInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: self.contentInsets)
    }

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.clearButtonRect(forBounds: bounds)
        return rect.insetBy(dx: self.clearButtonOffset.x,
                            dy: self.clearButtonOffset.y)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard isActionMenuEnabled else {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
