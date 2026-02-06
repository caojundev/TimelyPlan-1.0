//
//  UIView+Swizzler.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/25.
//

import Foundation

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
    }
}
