//
//  UIView+Swizzler.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/25.
//

import Foundation
import UIKit

extension UIView {
    
    static func swizzleUIViewMethods() {
        swizzleInstanceMethod(UIView.self,
                              #selector(layoutSubviews),
                              #selector(tf_UIViewLayoutSubviews))
    }
    
    @objc private func tf_UIViewLayoutSubviews() {
        self.tf_UIViewLayoutSubviews()
        
        /// 布局分割线
        layoutSeparator()
        
        /// 更新主题
        themeDidChange()
        
        /// 布局骨架
        sk_layoutSubviews()
    }
}
