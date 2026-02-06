//
//  UIScrollView+Scroll.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/3.
//

import Foundation
import UIKit

extension UIScrollView {
    
    /// 将一个给定的 rect 滑动到 scrollView 的居中位置
    func scrollRectToVisibleCenter(_ rect: CGRect, animated: Bool) {
        let x = rect.origin.x + rect.size.width / 2.0 - self.frame.size.width / 2.0
        let y = rect.origin.y + rect.size.height / 2.0 - self.frame.size.height / 2.0
        let visibleRect = CGRect(x: x,
                                 y: y,
                                 width: self.frame.size.width,
                                 height: self.frame.size.height)
        self.scrollRectToVisible(visibleRect, animated: animated)
    }
}
