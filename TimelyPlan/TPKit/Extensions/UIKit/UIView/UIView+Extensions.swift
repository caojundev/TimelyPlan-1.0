//
//  UIView+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/10.
//

import Foundation
import UIKit

extension UIView {
    
    /// 查找类型为 UIScrollView 的父视图
    func scrollViewSuperview() -> UIScrollView? {
           if let scrollView = self as? UIScrollView {
               return scrollView // 如果当前视图本身就是 UIScrollView，则返回自身
           }
           
           guard let superview = superview else {
               return nil // 如果没有父视图，则返回 nil
           }
           
           return superview.scrollViewSuperview() // 递归调用父视图的方法
    }
    
    /// 第一响应者是否为当前视图的子视图
    var isDescendantFirstResponder: Bool {
        let responder = UIResponder.currentFirstResponder()
        if let view = responder as? UIView, view.isDescendant(of: self) {
            return true
        }
        
        return false
    }
    
    /// 将数组中视图从父视图移除
    func removeViews(_ views: [UIView]) {
        views.forEach { view in
            view.removeFromSuperview()
        }
    }
    
    /// 移除当前视图所有子视图
    func removeAllSubviews() {
        while self.subviews.count != 0 {
            let subview = self.subviews.last
            subview?.removeFromSuperview()
        }
    }
    
    ///
    func tp_snapshotView(cornerRadius: CGFloat = 0.0) -> UIView {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIView()
        }
        
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = cornerRadius
        snapshot.clipsToBounds = true
        
        let draggingView = UIView(frame: bounds)
        draggingView.layer.cornerRadius = cornerRadius
        draggingView.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        draggingView.layer.shadowOffset = .zero
        draggingView.layer.shadowRadius = 8.0
        draggingView.layer.shadowOpacity = 0.1
        draggingView.addSubview(snapshot)
        return draggingView
    }
    
}

// MARK: - 阴影
extension UIView {
    func tp_setViewShadow(color: UIColor, offset: CGSize, radius: CGFloat) {
        self.layer.setLayerShadow(color: color, offset: offset, radius: radius)
    }

    func tp_setViewShadow(path: CGPath, color: UIColor, offset: CGSize, radius: CGFloat) {
        self.layer.setLayerShadow(path: path, color: color, offset: offset, radius: radius)
    }

    func tp_setBorderShadow(color: UIColor = .shadow,
                         offset: CGSize = .zero,
                         radius: CGFloat) {
        self.layer.setBorderShadow(color: color, offset: offset, radius: radius)
    }

    func tp_setBorderShadow(color: UIColor,
                            offset: CGSize,
                            radius: CGFloat,
                            roundCorners corners: UIRectCorner,
                            cornerRadius: CGFloat) {
        self.layer.setBorderShadow(color: color, offset: offset, radius: radius, roundCorners: corners, cornerRadius: cornerRadius)
    }

    func tp_removeShadow() {
        self.layer.removeShadow()
    }
}

