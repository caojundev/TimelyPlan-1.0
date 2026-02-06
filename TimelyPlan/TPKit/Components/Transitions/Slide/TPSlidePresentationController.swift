//
//  TPSlidePresentationController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/6.
//

import Foundation
import UIKit

class TPSlidePresentationController: UIPresentationController {
    
    var configure = TPSlidePresentationConfigure()
    
    private var contentPadding: UIEdgeInsets = .zero
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.alpha = 0.0
        
        /// 添加单击手势
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handDimmingViewTap(_:)))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presenting)
        addKeyboardNotification()
    }
    
    deinit {
        removeKeyboardNotification()
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let containerView = self.containerView else {
            return
        }
        
        self.dimmingView.frame = containerView.bounds
        self.updatePresentedViewFrame(animated: false)
        self.updateRoundCorners()
        self.updateShadow()
        self.presentingViewController.view.frame = endFrameOfPresentingViewInContainerView()
    }

    private func updatePresentedViewFrame(animated: Bool) {
        let newFrame = self.frameOfPresentedViewInContainerView
        guard shadowView.frame != newFrame else {
            return
        }
    
        let animations = {
            self.shadowView.frame = newFrame
            self.presentedView?.frame = self.shadowView.bounds
//            self.updateRoundCorners()
//            self.updateShadow()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: animations,
                           completion: nil)
        } else {
            animations()
        }
    }
    
    private func updateShadow() {
        let path = UIBezierPath.init(roundedRect: self.shadowView.bounds,
                                     byRoundingCorners: configure.roundingCorners,
                                     cornerRadii: configure.cornerRadii)
        self.shadowView.layer.shadowPath = path.cgPath
        self.shadowView.layer.shadowColor = configure.shadowColor.cgColor
        self.shadowView.layer.shadowOffset = configure.shadowOffset
        self.shadowView.layer.shadowRadius = configure.shadowRadius
        self.shadowView.layer.shadowOpacity = 0.2;
        self.shadowView.layer.shouldRasterize = true
        self.shadowView.layer.rasterizationScale = UIScreen.main.scale
    }

    /// 更新圆角
    private func updateRoundCorners() {
        guard let presentedView = self.presentedView else {
            return
        }
        
        let maskPath = UIBezierPath(roundedRect: presentedView.bounds,
                                    byRoundingCorners: configure.roundingCorners,
                                    cornerRadii: configure.cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        presentedView.layer.mask = maskLayer
    }

    // MARK: - 布局
    func initialFrameOfPresentingViewInContainerView() -> CGRect {
        let presentingFrame = self.presentingViewController.view.frame
        if configure.direction == .right,
            let containerView = self.containerView,
           presentingFrame.size == containerView.size {
            return containerView.bounds
        }
        
        return presentingFrame
    }
    
    func endFrameOfPresentingViewInContainerView() -> CGRect {
        let presentingFrame = self.presentingViewController.view.frame
        guard let containerView = self.containerView, configure.direction == .right else {
            return presentingFrame
        }

        guard UITraitCollection.isCompactMode() else {
            return presentingFrame.size == containerView.size ? containerView.bounds : presentingFrame
        }
        
        let presentedFrame = frameOfPresentedViewInContainerView
        if presentingFrame.size == containerView.size, presentedFrame.size == containerView.size {
            return CGRect(x: -containerView.width / 3.0, y: 0.0, size: presentingFrame.size)
        }
        
        return presentingFrame
    }
    
    /// 动画开始前的初始位置
    func initialFrameOfPresentedViewInContainerView() -> CGRect {
        guard let containerView = self.containerView else {
            return .zero
        }
        
        let finalRect = self.frameOfPresentedViewInContainerView
        var initialRect = finalRect
        switch configure.direction {
        case .top:
            initialRect.origin.y = -finalRect.size.height
        case .left:
            initialRect.origin.x = -finalRect.size.width
        case .bottom:
            initialRect.origin.y = containerView.height + containerView.safeAreaInsets.bottom
        case .right:
            initialRect.origin.x = containerView.width
        }
        
        return initialRect
    }
    
    /// 内容尺寸
    var contentSize: CGSize {
        var size = configure.contentSize
        if size == .zero {
            size = self.presentedViewController.preferredContentSize
        }
        
        return size
    }
    
    /// 边界间距
    var edgeInsets: UIEdgeInsets {
        let insets = configure.edgeInsets
        if insets == .zero {
            return .zero
        }

        guard let containerView = self.containerView else {
            return .zero
        }
        
        let margins = containerView.layoutMargins
        let top = insets.top + margins.top
        let left = insets.left + margins.left
        let bottom = insets.bottom + margins.bottom
        let right = insets.right + margins.right
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    var contentLayoutFrame: CGRect {
        guard let containerView = self.containerView else {
            return .zero
        }
        
        var edgeInsets = self.edgeInsets
        if (configure.automaticallyAdjustsForKeyboard) {
            /// 是否根据
            let top = max(edgeInsets.top, self.contentPadding.top);
            let left = max(edgeInsets.left, self.contentPadding.left);
            let bottom = max(edgeInsets.bottom, self.contentPadding.bottom);
            let right = max(edgeInsets.right, self.contentPadding.right);
            edgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        return containerView.bounds.inset(by: edgeInsets)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = self.containerView else {
            return .zero
        }

        let sourceContainerRect = containerView.bounds
        var contentSize = self.contentSize
        if contentSize == .zero {
            contentSize = sourceContainerRect.size
        }
        
        var width = min(configure.maximumWidth, max(configure.minimumWidth, contentSize.width))
        var height = min(configure.maximumHeight, max(configure.minimumHeight, contentSize.height))
        let layoutFrame = self.contentLayoutFrame
        width = min(width, layoutFrame.size.width);
        height = min(height, layoutFrame.size.height);

        /// 计算横坐标
        var x = 0.0
        let position = configure.presentPosition
        switch position {
        case .left:
            x = layoutFrame.minX
        case .right:
            x = layoutFrame.maxX - width
        default:
            x = layoutFrame.minX + (layoutFrame.width - width) / 2.0
        }
        
        /// 计算纵坐标
        var y = 0.0
        var shouldAdjustHeight = false
        switch position {
        case .top:
            y = layoutFrame.minY
        case .bottom:
            y = layoutFrame.maxY - height
            shouldAdjustHeight = true
        default:
            y = layoutFrame.minY + (layoutFrame.height - height) / 2.0
        }
        
        var presentedFrame = CGRect(x: x, y: y, width: width, height: height)
        let containerLayoutFrame = containerView.safeAreaFrame()
        if shouldAdjustHeight && presentedFrame.maxY > containerLayoutFrame.maxY {
            /// 调整高度
            let dy = presentedFrame.maxY - containerLayoutFrame.maxY
            presentedFrame =  CGRect(x: x, y: y - dy, width: width, height: height + dy)
        }
    
        return presentedFrame
    }
    
    // MARK: - 键盘通知
    private var isDescendantResponder: Bool {
        if let containerView = self.containerView,
           UIResponder.isCurrentFirstResponderDescendantView(of: containerView) {
            return true
        }
        
        return false
    }
    
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard isDescendantResponder,
              let containerView = self.containerView,
                let userInfo = notification.userInfo,
                let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
    
        let offsetY: CGFloat = 0.0
        /// 根据y间距调整键盘 frame 信息
        var keyboardFrame = frameValue.cgRectValue
        keyboardFrame.origin.y -= offsetY
        keyboardFrame.size.height += offsetY
        
        let contentPadding = UIEdgeInsets(bottom: containerView.height - keyboardFrame.minY)
        guard self.contentPadding != contentPadding else {
            return
        }
        
        self.contentPadding = contentPadding
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.containerView?.setNeedsLayout()
            self.containerView?.layoutIfNeeded()
        }, completion: nil)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard isDescendantResponder else {
            return
        }

        guard self.contentPadding != .zero else {
            return
        }
        
        self.contentPadding = .zero
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.containerView?.setNeedsLayout()
            self.containerView?.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - 过渡的开始和结束
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else {
            return
        }
    
        /// 背景视图
        self.dimmingView.backgroundColor = configure.maskColor
        self.dimmingView.frame = containerView.frame
        containerView.addSubview(self.dimmingView)
        containerView.addSubview(self.shadowView)
        

        let initialFrameOfPresentedView = initialFrameOfPresentedViewInContainerView()
        
        let presentedView: UIView = self.presentedViewController.view
        self.shadowView.frame = initialFrameOfPresentedView
        presentedView.frame = self.shadowView.bounds
        self.shadowView.addSubview(presentedView)
        self.updateShadow()
        self.updateRoundCorners()
        
        let animations = {
            self.shadowView.frame = self.frameOfPresentedViewInContainerView
            self.dimmingView.alpha = 1.0
        }
        
        if let coordinator = self.presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                animations()
            }, completion: nil)
        } else {
            animations()
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
//            self.shadowView.removeFromSuperview()
            self.dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let animations = {
            self.shadowView.frame = self.initialFrameOfPresentedViewInContainerView()
            self.dimmingView.alpha = 0.0;
        }
        
        if let coordinator = self.presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                animations()
            }, completion: nil)
        } else {
            animations()
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
//            self.shadowView.removeFromSuperview()
            self.dimmingView.removeFromSuperview()
        }
    }
    
    // MARK: - Event Response
    @objc func handDimmingViewTap(_ recognizer: UITapGestureRecognizer) {
        if configure.shouldDismissWhenTapOnMask {
            self.presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
}
