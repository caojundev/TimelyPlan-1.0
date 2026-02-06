//
//  UIView+FrameLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/5.
//

import Foundation
import UIKit

extension UIView {
    
    func contentSafeLayoutFrame() -> CGRect {
        return contentSafeLayoutFrame(withPadding: .zero)
    }
    
    func contentSafeLayoutFrame(withPadding padding: UIEdgeInsets) -> CGRect {
        var layoutFrame = safeAreaFrame()
        
        // Choose the shorter edge for content width
        let contentWidth = min(layoutFrame.size.width, layoutFrame.size.height)
        layoutFrame.origin.x = layoutFrame.origin.x + (layoutFrame.size.width - contentWidth) / 2.0
        layoutFrame.size.width = contentWidth
        layoutFrame = layoutFrame.inset(by: padding)
        return layoutFrame
    }
    
    func safeAreaFrame() -> CGRect {
        return safeAreaLayoutGuide.layoutFrame
    }
    
    var safeOrigin: CGPoint {
        return safeAreaFrame().origin
    }
    
    var safeLeft: CGFloat {
        return safeOrigin.x
    }
    
    var safeRight: CGFloat {
        return safeLeft + safeWidth
    }
    
    var safeTop: CGFloat {
        return safeOrigin.y
    }
    
    var safeBottom: CGFloat {
        return safeTop + safeHeight
    }
    
    var safeSize: CGSize {
        return safeAreaFrame().size
    }
    
    var safeWidth: CGFloat {
        return safeAreaFrame().size.width
    }
    
    var safeHalfWidth: CGFloat {
        return safeWidth / 2.0
    }
    
    var safeHeight: CGFloat {
        return safeAreaFrame().size.height
    }
    
    var safeHalfHeight: CGFloat {
        return safeHeight / 2.0
    }
    
    var safeCenter: CGPoint {
        return CGPoint(x: safeCenterX, y: safeCenterY)
    }
    
    var safeCenterX: CGFloat {
        return safeLeft + safeHalfWidth
    }
    
    var safeCenterY: CGFloat {
        return safeTop + safeHalfHeight
    }
    
    func alignSafeCenter() {
        guard let aSuperview = self.superview else { return }
        self.center = aSuperview.safeCenter
    }
    
    func alignSafeHorizontalCenter() {
        guard let aSuperview = self.superview else { return }
        self.centerX = aSuperview.safeCenterX
    }
    
    func alignSafeVerticalCenter() {
        guard let aSuperview = self.superview else { return }
        self.centerY = aSuperview.safeCenterY
    }

    // MARK: - Origin
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        
        set(origin){
            var frame = self.frame
            frame.origin = origin
            self.frame = frame
        }
    }
    
    var originX: CGFloat {
        get {
            return self.frame.origin.x
        }
        
        set(originX){
            self.frame = CGRect(x: originX,
                                y: self.frame.origin.y,
                                width: self.frame.size.width,
                                height: self.frame.size.height)
        }
    }
    
    var originY: CGFloat {
        get {
            return self.frame.origin.y
        }
        
        set(originY){
            self.frame = CGRect(x: self.frame.origin.x,
                                y: originY,
                                width: self.frame.size.width,
                                height: self.frame.size.height)
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        
        set(top){
            self.originY = top
        }
    }

    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        
        set(left){
            self.originX = left
        }
    }

    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        
        set(bottom){
            let top = bottom - self.frame.size.height
            self.originY = top
        }
    }
    
    var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        
        set(maxX){
            let left = maxX - self.frame.size.width
            self.originX = left
        }
    }
    
    // MARK: - 尺寸
    var size: CGSize {
        get {
            if let _ = self as? UIScrollView {
                return frame.size
            }
            
            return bounds.size
        }
        
        set(size){
            var frame = self.frame;
            frame.size = size;
            self.frame = frame
        }
    }
    
    var width: CGFloat {
        get {
            if let _ = self as? UIScrollView {
                return self.frame.size.width
            }
            
            return self.bounds.size.width
        }
        
        set(width){
            self.frame = CGRect(x: self.frame.origin.x,
                                y: self.frame.origin.y,
                                width: width,
                                height: self.frame.size.height)
        }
    }
    
    var halfWidth: CGFloat {
        return width / 2
    }
    
    var height: CGFloat {
        get {
            if let _ = self as? UIScrollView {
                return self.frame.size.height
            }
            
            return self.bounds.size.height
        }
        
        set(height){
            self.frame = CGRect(x: self.frame.origin.x,
                                y: self.frame.origin.y,
                                width: self.frame.size.width,
                                height: height)
        }
    }

    var halfHeight: CGFloat {
        return height / 2
    }
    
    
    // MARK: - 居中
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        
        set(centerX){
            self.center = CGPoint(x: centerX, y: self.center.y)
        }
    }

    var centerY: CGFloat {
        get {
            return self.center.y
        }
        
        set(centerY){
            self.center = CGPoint(x: self.center.x, y: centerY)
        }
    }
    
    // MARK: - Alignment
    func alignCenter() {
        guard let aSuperview = self.superview else { return }
        self.center = CGPoint(x: aSuperview.bounds.size.width / 2,
                              y: aSuperview.bounds.size.height / 2)
    }

    func alignHorizontalCenter() {
        guard let aSuperview = self.superview else { return }
        self.centerX = aSuperview.halfWidth
    }

    func alignVerticalCenter() {
        guard let aSuperview = self.superview else { return }
        self.centerY = aSuperview.halfHeight
    }
    
    func alignHorizontalCenter(between leftView: UIView, rightView: UIView) {
        self.centerX = leftView.right + (rightView.left - leftView.right) / 2.0
    }
    
    func alignVerticalCenter(between topView: UIView, bottomView: UIView) {
        self.centerY = topView.bottom + (bottomView.top - topView.bottom) / 2.0
    }
    
    // MARK: - 视图
    /// 获取当前 View 最顶层父视图
    var topSuperView: UIView {
        var topSuperView = self.superview
        if topSuperView == nil {
            topSuperView = self
        } else {
            while topSuperView?.superview != nil {
                topSuperView = topSuperView?.superview
            }
        }
        
        return topSuperView!
    }
    
    // MARK: - Origin Equal
    func convertedOrigin(from view: UIView) -> CGPoint {
        let viewSuperView = view.superview ?? view
        let topSuperView = self.topSuperView
        let viewOrigin = viewSuperView.convert(view.origin, to: topSuperView)
        let newOrigin = topSuperView.convert(viewOrigin, to: self.superview)
        return newOrigin
    }

    func originEqualToView(_ view: UIView) {
        let newOrigin = convertedOrigin(from: view)
        self.origin = newOrigin
    }

    func originXEqualToView(_ view: UIView) {
        let newOrigin = convertedOrigin(from: view)
        self.originX = newOrigin.x
    }

    func originYEqualToView(_ view: UIView) {
        let newOrigin = convertedOrigin(from: view)
        self.originY = newOrigin.y
    }

    func topEqualToView(_ view: UIView) {
        originYEqualToView(view)
    }

    func leftEqualToView(_ view: UIView) {
        originXEqualToView(view)
    }

    func rightEqualToView(_ view: UIView) {
        let newOrigin = convertedOrigin(from: view)
        let originX = newOrigin.x + view.width - self.width
        self.originX = originX
    }

    func bottomEqualToView(_ view: UIView) {
        let newOrigin = convertedOrigin(from: view)
        let originY = newOrigin.y + view.height - self.height
        self.originY = originY
    }

    // MARK: - Size Equal
    func sizeEqualToView(_ view: UIView) {
        self.size = view.size
    }

    func widthEqualToView(_ view: UIView) {
        self.width = view.width
    }

    func heightEqualToView(_ view: UIView) {
        self.height = view.height
    }

    // MARK: - Center Equal
    func convertedCenter(from view: UIView) -> CGPoint {
        let viewSuperView = view.superview ?? view
        let topSuperView = self.topSuperView
        let viewCenter = viewSuperView.convert(view.center, to: topSuperView)
        let newCenter = topSuperView.convert(viewCenter, to: self.superview)
        return newCenter
    }

    func centerEqualToView(_ view: UIView) {
        let newCenter = self.convertedCenter(from: view)
        self.center = newCenter
    }

    func centerXEqualToView(_ view: UIView) {
        let newCenter = self.convertedCenter(from: view)
        self.centerX = newCenter.x
    }

    func centerYEqualToView(_ view: UIView) {
        let newCenter = self.convertedCenter(from: view)
        self.centerY = newCenter.y
    }

    // MARK: - Distance from view
    ///< 相对其他视图一段距离
    func marginTop(_ margin: CGFloat, ofView view: UIView) {
        let newOrigin = self.convertedOrigin(from: view)
        let originY = newOrigin.y + margin
        self.originY = originY
    }

    func marginLeft(_ margin: CGFloat, ofView view: UIView) {
        let newOrigin = self.convertedOrigin(from: view)
        let originX = newOrigin.x + margin
        self.originX = originX
    }

    func marginRight(_ margin: CGFloat, ofView view: UIView) {
        let newOrigin = self.convertedOrigin(from: view)
        let originX = newOrigin.x + view.width + margin
        self.originX = originX
    }

    func marginBottom(_ margin: CGFloat, ofView view: UIView) {
        let newOrigin = self.convertedOrigin(from: view)
        let originY = newOrigin.y + view.height + margin
        self.originY = originY
    }
}

extension UIView {
    
    private struct AssociatedKeys {
        static var padding = "padding"
    }
    
    var padding: UIEdgeInsets {
        get {
            return associated.get(&AssociatedKeys.padding) ?? .zero
        }
        
        set {
            associated.set(retain: &AssociatedKeys.padding, newValue)
        }
    }
       
    func safeLayoutFrame() -> CGRect {
        var frame = safeAreaFrame().inset(by: padding)
        if frame.size.width < 0.0 {
            frame.size.width = 0.0
        }
        
        if frame.size.height < 0.0 {
            frame.size.height = 0.0
        }
        
        return frame
    }
    
    func layoutFrame() -> CGRect {
        var frame = bounds.inset(by: padding)
        if frame.size.width < 0.0 {
            frame.size.width = 0.0
        }
        
        if frame.size.height < 0.0 {
            frame.size.height = 0.0
        }
        
        return frame
    }
}
