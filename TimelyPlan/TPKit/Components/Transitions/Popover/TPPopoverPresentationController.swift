//
//  TPPopoverPresentationController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/9.
//

import Foundation
import UIKit

class TPPopoverPresentationController: UIPresentationController {
    
    var configure = TPPopoverPresentationConfigure()
    
    var sourceViewController: UIViewController!
    
    /// 键盘顶部与控件的间距
    var keyboardOffsetY: CGFloat = 10.0

    /// 默认内容尺寸
    let defaultContentSize = CGSize(width: 460.0, height: 240.0)

    /// 弹窗边界间距
    private var popoverLayoutMargins: UIEdgeInsets = .zero
    
    /// 当前实际显示位置
    private var position: TPPopoverPosition = .center
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
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
    
    @objc func handDimmingViewTap(_ recognizer: UITapGestureRecognizer) {
        if configure.shouldDismissWhenTapOnMask {
            self.presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
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
        self.presentedView?.layer.anchorPoint = anchorPoint(for: self.position)
        self.updateRoundCorners()
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        self.updateCurrentPosition() /// 更新锚点位置
        let frame = availablePopoverFrame(for: self.contentSize, position: self.position)
        return frame
    }
    
    private func updateCurrentPosition() {
        self.position = configure.preferredPosition
        let contentSize = self.contentSize
        var popoverFrame = availablePopoverFrame(for: contentSize, position: configure.preferredPosition)
        if popoverFrame.size == contentSize {
            return
        }
        
        /// 检查其它允许弹窗位置
        for permittedPosition in configure.permittedPositions {
            if permittedPosition == configure.preferredPosition {
                continue
            }
            
            let frame = availablePopoverFrame(for: contentSize, position: permittedPosition)
            if frame.size == contentSize {
                self.position = permittedPosition
                break
            }
            
            /// 计算显示区域面积
            if frame.size.width * frame.size.height > popoverFrame.size.width * popoverFrame.size.height {
                self.position = permittedPosition
                popoverFrame = frame
            }
        }
    }

    // MARK: - Update UI
    private func updateRoundCorners() {
        self.presentedView?.clipsToBounds = true
        self.presentedView?.layer.cornerRadius = configure.cornerRadius
    }

    private func updatePresentedViewFrame(animated: Bool) {
        guard let presentedView = self.presentedView else {
            return
        }
        
        let newFrame = self.frameOfPresentedViewInContainerView
        presentedView.layer.anchorPoint = anchorPoint(for: self.position)
        guard presentedView.frame != newFrame else {
            return
        }
        
        let animations = {
            presentedView.frame = newFrame
            self.updateRoundCorners()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: animations, completion: nil)
        } else {
            animations()
        }
    }

    // MARK: - 过渡的开始和结束
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else {
            return
        }
    
        if observeViews.count == 0 {
            addSourceViewFrameObserver()
        }
        
        /// 背景视图
        self.dimmingView.backgroundColor = configure.maskColor
        self.dimmingView.alpha = 0.0
        self.dimmingView.frame = containerView.frame
        containerView.addSubview(self.dimmingView)
        
        let presentedView: UIView = self.presentedViewController.view
        containerView.addSubview(presentedView)
        self.updatePresentedViewFrame(animated: false)
        presentedView.transform = .init(scaleX: 0.1, y: 0.1)
    
        let animations = {
            self.dimmingView.alpha = 1.0;
            presentedView.transform = .identity
        };

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
            self.dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        removeSourceViewFrameObserver()
        let animations = {
            self.dimmingView.alpha = 0.0
            self.presentedView?.alpha = 0.0
            self.presentedView?.transform = .init(scaleX: 0.1, y: 0.1)
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
            self.dimmingView.removeFromSuperview()
        }
    }
    
    // MARK: - Frame Observer
    private var observeViews: [UIView] = []
    private func addSourceViewFrameObserver() {
        guard let sourceView = configure.sourceView ?? self.containerView else {
            return
        }
        
        iterateSubviews(sourceView) { view in
            view.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
            observeViews.append(view)
        }
    }

    private func removeSourceViewFrameObserver() {
        for view in observeViews {
            view.removeObserver(self, forKeyPath: "frame")
        }
    }

    /// 监听 frame 改变
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        /// 容器视图需要重新布局
        self.sourceViewController.view.layoutIfNeeded()
        self.containerView?.setNeedsLayout()
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
    
        /// 根据y间距调整键盘 frame 信息
        var keyboardFrame = frameValue.cgRectValue
        keyboardFrame.origin.y -= keyboardOffsetY
        keyboardFrame.size.height += keyboardOffsetY
        
        var layoutMargins = self.defaultLayoutMargins
        layoutMargins.bottom = containerView.height - keyboardFrame.minY
        guard self.popoverLayoutMargins != layoutMargins else {
            return
        }
        
        self.popoverLayoutMargins = layoutMargins
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.containerView?.setNeedsLayout()
            self.containerView?.layoutIfNeeded()
        }, completion: nil)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard isDescendantResponder else {
            return
        }
        
        let layoutMargins = self.defaultLayoutMargins
        guard self.popoverLayoutMargins != layoutMargins else {
            return
        }
        
        self.popoverLayoutMargins = layoutMargins
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.containerView?.setNeedsLayout()
            self.containerView?.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - 布局相关
    var contentSize: CGSize {
        var size = self.presentedViewController.preferredContentSize
        if size == .zero {
            size = defaultContentSize
        }
        
        return size
    }
    
    var defaultLayoutMargins: UIEdgeInsets {
        let margins = configure.layoutMargins
        var insets = self.containerView?.safeAreaInsets ?? .zero
        insets.top = insets.top + margins.top
        insets.left = insets.left + margins.left
        insets.bottom = insets.bottom + margins.bottom
        insets.right = insets.right + margins.right
        return insets
    }
    
    /// 获取对应位置布局区域信息
    func availablePopoverFrame(for contentSize: CGSize, position: TPPopoverPosition) -> CGRect {
        guard let containerView = self.containerView else {
            return .zero
        }
        
        var fromPoint = fromPoint(for: configure.sourceView,
                                     sourceRect: configure.sourceRect,
                                     position: position,
                                     isCovered: configure.isSourceViewCovered)
        
        let margins = self.defaultLayoutMargins
        let popoverLayoutMargins = self.popoverLayoutMargins
        let layoutMargins = UIEdgeInsets(top: max(margins.top, popoverLayoutMargins.top),
                                         left: max(margins.left, popoverLayoutMargins.left),
                                         bottom:max(margins.bottom, popoverLayoutMargins.bottom),
                                         right: max(margins.right, popoverLayoutMargins.right))
        let layoutFrame = containerView.bounds.inset(by: layoutMargins)
        if !layoutFrame.contains(fromPoint) {
            /// 调整fromPoint位置
            fromPoint.x = min(layoutFrame.maxX, max(layoutFrame.minX, fromPoint.x))
            fromPoint.y = min(layoutFrame.maxY, max(layoutFrame.minY, fromPoint.y))
        }
        
        let popoverFrame = popoverFrame(from: fromPoint,
                                        contentSize: contentSize,
                                        position: position)
        return layoutFrame.intersection(popoverFrame)
    }

    func fromPoint(for sourceView: UIView?,
                   sourceRect: CGRect,
                   position: TPPopoverPosition,
                   isCovered: Bool = false) -> CGPoint {
        let fromRect = self.fromRect(for: sourceView, sourceRect: sourceRect)
        var fromPoint: CGPoint

        switch position {
        case .topLeft:
            fromPoint = isCovered ? fromRect.bottomRight : fromRect.topRight
            
        case .topCenter:
            fromPoint = isCovered ? fromRect.bottomMid : fromRect.topMid
            
        case .topRight:
            fromPoint = isCovered ? fromRect.bottomLeft : fromRect.topLeft
            
        case .bottomLeft:
            fromPoint = isCovered ? fromRect.topRight : fromRect.bottomRight
            
        case .bottomCenter:
            fromPoint = isCovered ? fromRect.topMid : fromRect.bottomMid
            
        case .bottomRight:
            fromPoint = isCovered ? fromRect.topLeft : fromRect.bottomRight
            
        case .centerLeft:
            fromPoint = isCovered ? fromRect.rightMid : fromRect.leftMid
            
        case .centerRight:
            fromPoint = isCovered ? fromRect.leftMid : fromRect.rightMid
            
        default:
            fromPoint = fromRect.center
        }

        return fromPoint
    }

    func fromRect(for sourceView: UIView?, sourceRect: CGRect) -> CGRect {
        var fromRect: CGRect
        if let sourceView = sourceView {
            let fromOrigin = sourceView.convert(CGPoint.zero, toViewOrWindow: containerView)
            fromRect = CGRect(x: fromOrigin.x + sourceRect.origin.x,
                              y: fromOrigin.y + sourceRect.origin.y,
                              width: sourceRect.width,
                              height: sourceRect.height)
        } else {
            fromRect = containerView?.safeAreaFrame().inset(by: popoverLayoutMargins) ?? .zero
        }
        
        return fromRect;
    }

    /// 获取弹窗区域信息
    /// @param point 弹窗点
    /// @param contentSize 窗口内容大小
    /// @param position 弹窗显示位置
    func popoverFrame(from point: CGPoint, contentSize: CGSize, position: TPPopoverPosition) -> CGRect {
        let w = contentSize.width
        let h = contentSize.height
        var frame = CGRect(x: 0, y: 0, size: contentSize)

        switch position {
        case .topLeft:
            frame.origin = CGPoint(x: point.x - w, y: point.y - h)
            
        case .topCenter:
            frame.origin = CGPoint(x: point.x - w / 2.0, y: point.y - h)
            
        case .topRight:
            frame.origin = CGPoint(x: point.x, y: point.y - h)
            
        case .bottomLeft:
            frame.origin = CGPoint(x: point.x - w, y: point.y)
            
        case .bottomCenter:
            frame.origin = CGPoint(x: point.x - w / 2.0, y: point.y)
            
        case .bottomRight:
            frame.origin = point
            
        case .centerLeft:
            frame.origin = CGPoint(x: point.x - w, y: point.y - h / 2.0)
            
        case .centerRight:
            frame.origin = CGPoint(x: point.x, y: point.y - h / 2.0)
            
        default:
            frame.origin = CGPoint(x: point.x - w / 2.0, y: point.y - h / 2.0)
        }

        return frame
    }

    // MARK: - 锚点
    func anchorPoint(for position: TPPopoverPosition) -> CGPoint {
        var anchorPoint: CGPoint = .zero
        switch position {
        case .center:
            anchorPoint = CGPoint(0.5, 0.5)
        case .topLeft:
            anchorPoint = CGPoint(1.0, 1.0)
        case .topCenter:
            anchorPoint = CGPoint(0.5, 1.0)
        case .topRight:
            anchorPoint = CGPoint(0.0, 1.0)
        case .bottomLeft:
            anchorPoint = CGPoint(1.0, 0.0)
        case .bottomCenter:
            anchorPoint = CGPoint(0.5, 0.0)
        case .bottomRight:
            anchorPoint = CGPoint(0.0, 0.0)
        case .centerLeft:
            anchorPoint = CGPoint(1.0, 0.5)
        case .centerRight:
            anchorPoint = CGPoint(0.0, 0.5)
        }
        
        return anchorPoint
    }

    // MARK: - Helpers
    private func iterateSubviews(_ sourceView: UIView?, action: (UIView) -> Void) {
        guard let sourceView = sourceView else {
            return
        }

        var nextResponder = sourceView.next
        while nextResponder != nil {
            if let view = nextResponder as? UIView {
                action(view)
            } else if let viewController = nextResponder as? UIViewController {
                action(viewController.view)
            }

            nextResponder = nextResponder?.next
        }
    }
}
