//
//  UIViewController+PopoverContent.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/28.
//

import Foundation
import UIKit

protocol TFPopoverContent {
    
    /// 内容尺寸
    var popoverContentSize: CGSize { get }
}

extension UIViewController: TFPopoverContent {
    
    @objc var popoverContentSize: CGSize {
        return kPopoverPreferredContentSize
    }
    
    /// 更新内容大小
    func updatePopoverContentSize(animated: Bool = false) {
        DispatchQueue.main.async {
            let contentSize = self.popoverContentSize
            self.setContentSize(contentSize, animated: animated)
        }
    }
    
}
