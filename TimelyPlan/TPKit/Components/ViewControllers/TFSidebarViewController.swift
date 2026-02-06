//
//  TPSidebarViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/5.
//

import Foundation
import UIKit

class TPSidebarViewController: UIViewController,
                                    UIGestureRecognizerDelegate,
                                    TPColumnContainerViewDelegate {
    
    /// 侧边栏宽度
    var sidebarWidth: CGFloat = 200.0
    
    /// 非活动边栏在最左端隐藏的宽度
    var inactiveColumnHiddenWidth: CGFloat = 120.0
    
    /// 变成第一活动状态的触发距离
    var firstActiveTriggerDistance: CGFloat = 50.0
    
    /// 边界手势触发宽度
    var edgeGestureTriggerWidth: CGFloat = 50.0
    
    /// 边缘移动因子
    var edgeMoveFactor = 0.1
    
    /// 分割线颜色
    var separatorColor: UIColor = .separator {
        didSet {
            detailContainerView.separatorColor = separatorColor
        }
    }
    
    /// 内容视图
    private var contentView = UIView()

    lazy var sidebarContainerView: TPColumnContainerView = {
        let view = TPColumnContainerView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    lazy var detailContainerView: TPColumnContainerView = {
        let view = TPColumnContainerView()
        view.backgroundColor = .systemBackground
        view.addSeparator(position: .left, color: .separator)
        view.delegate = self
        return view
    }()
    
    /// 边栏视图控制器
    var sidebarViewController: UIViewController?

    /// 内容视图控制器
    var detailViewController: UIViewController?
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        recognizer.isEnabled = true
        recognizer.delegate = self
        recognizer.maximumNumberOfTouches = 1
        return recognizer
    }()
    
    /// 边缘阴影颜色
    var edgeShadowColor = Color(0x000000, 0.2)

    /// 是否展开侧边栏
    var isExpand: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.isMultipleTouchEnabled = false
        self.contentView.isExclusiveTouch = true
        self.contentView.addGestureRecognizer(self.panGestureRecognizer)
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.sidebarContainerView)
        self.contentView.addSubview(self.detailContainerView)

        if let sidebarViewController = sidebarViewController {
            self.addSubviewController(sidebarViewController)
            self.sidebarContainerView.viewController = sidebarViewController
        }
  
        if let detailViewController = detailViewController {
            self.addSubviewController(detailViewController)
            self.detailContainerView.viewController = detailViewController
        }
        
        self.updateContainerShadow() /// 更新阴影
        self.relayout()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.contentView.frame = view.bounds
        self.relayout()
    }

    private func relayout() {
        self.sidebarContainerView.frame = sidebarContainerRect
        self.detailContainerView.frame = detailContainerRect
        self.detailContainerView.layer.shadowOpacity = 0
        if (self.isExpand) {
            self.detailContainerView.separatorAlpha = 1
        } else {
            self.detailContainerView.separatorAlpha = 0
        }
    }
    
    var sidebarContainerRect: CGRect {
        var x: CGFloat = 0.0
        if (!isExpand) {
            x = -inactiveColumnHiddenWidth
        }
        
        return CGRect(x: x, y: 0.0, width: sidebarWidth, height: view.height)
    }

    var detailContainerRect: CGRect {
        var x: CGFloat = 0.0
        if (isExpand) {
            x = sidebarWidth
        }
        
        return CGRect(x: x, y: 0.0, size: view.size)
    }

    private func updateContainerShadow() {
        let views = [sidebarContainerView, detailContainerView]
        for view in views {
            view.clipsToBounds = false
            view.layer.shadowOpacity = 0.0
            view.layer.setLayerShadow(color: edgeShadowColor,
                                      offset: CGSize(width: -5.0, height: 0.0),
                                      radius: 8.0)
        }
    }

    
    // MARK: - 添加删除视图控制器
    func addSubviewController(_ viewController: UIViewController) {
        addChild(viewController)
        viewController.didMove(toParent: self)
    }

    func removeSubviewController(_ viewController: UIViewController) {
        viewController.view.removeFromSuperview()
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
    }
    
    // MARK: - 禁用/启用用户交互
    func enableDetailUserInteraction() {
        self.detailContainerView.enableUserInteraction()
    }

    func disableDetailUserInteraction() {
        self.detailContainerView.disableUserInteraction()
    }

    func setUserInteractionEnabled(_ enabled: Bool) {
        sidebarViewController?.view.isUserInteractionEnabled = enabled
        detailViewController?.view.isUserInteractionEnabled = enabled
    }

    // MARK: - 手势处理
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.contentView)
        switch recognizer.state {
        case .began:
            self.sidebarPanGestureRecognizerBegan()
            self.setUserInteractionEnabled(false)
        case .changed:
            self.sidebarPanGestureRecognizerChanged(translation)
        default:
            let velocity = recognizer.velocity(in: self.contentView)
            let info = shouldExpandAndUsingSpring(translation: translation, velocity: velocity)
            let shouldExpand = info.shouldExpand
            let usingSpring = info.usingSpring ///< 是否使用弹簧动画
            UIView.animate(withDuration: 0.45,
                           delay: 0.0,
                           usingSpringWithDamping: usingSpring ? 0.8 : 1.0,
                           initialSpringVelocity: 6.0,
                           options: .allowUserInteraction,
                           animations: {
                self.setExpand(shouldExpand, animated: false)
                self.relayout()
            }, completion: nil)
            
            self.setUserInteractionEnabled(true) /// 响应交互
            self.sidebarPanGestureRecognizerEnded()
        }
    }

    func sidebarPanGestureRecognizerBegan() {
        UIResponder.resignCurrentFirstResponder()
        /// 隐藏菜单
        if UIMenuController.shared.isMenuVisible {
            UIMenuController.shared.hideMenu()
        }
    }

    func sidebarPanGestureRecognizerEnded() {
        
    }
    
    func sidebarPanGestureRecognizerChanged(_ translation: CGPoint) {
        let dx = translation.x
        let detailOriginX = self.detailContainerView.frame.minX
        
        ///< 向左（相对于初始位置）
        if dx < 0 {
            var bMoveWithFactor = false
            if detailOriginX <= 0 {
                /// 内容页非全屏显示，并且此时活动列为最后一列，此时最后一列和detail一起移动
                bMoveWithFactor = true
            }
            
            /// 侧边栏
            var sidebarRect = self.sidebarContainerRect
            let leftMargin = sidebarRect.origin.x + dx
            if bMoveWithFactor {
                var x = leftMargin
                if x < 0 {
                    x *= self.edgeMoveFactor
                    /// 控制详细视图右侧的最大偏移
                    x = max(-firstActiveTriggerDistance / 2.0, x)
                }
                
                sidebarRect.origin.x = x
            } else {
                sidebarRect.origin.x = leftMargin * (inactiveColumnHiddenWidth / sidebarWidth)
            }
            
            self.sidebarContainerView.frame = sidebarRect
            
            /// 详细视图
            var detailRect = self.detailContainerRect
            detailRect.origin.x = max(0, detailRect.origin.x + dx)
            self.detailContainerView.frame = detailRect
            
            /// 详细视图阴影配置
            var shadowOpacity = (sidebarWidth - detailRect.origin.x) / firstActiveTriggerDistance
            shadowOpacity = max(0.0, min(shadowOpacity, 1.0))
            self.detailContainerView.layer.shadowOpacity = Float(shadowOpacity)
            self.detailContainerView.separatorAlpha = 1.0 - shadowOpacity
            
            let maskAlpha = detailRect.origin.x / sidebarWidth
            self.detailContainerView.coverMaskAlpha = maskAlpha
        } else {
            ///< 向右移动
            var rect = self.sidebarContainerRect
            let x = rect.origin.x + (inactiveColumnHiddenWidth / sidebarWidth) * dx
            rect.origin.x = min(0.0, x)
            self.sidebarContainerView.frame = rect
            
            var detailRect = self.detailContainerRect
            detailRect.origin.x += dx
            if detailRect.origin.x > sidebarWidth {
                detailRect.origin.x = sidebarWidth
            }
            
            self.detailContainerView.frame = detailRect
            
            ///< 阴影配置
            var shadowOpacity = (sidebarWidth - detailRect.origin.x) / firstActiveTriggerDistance
            shadowOpacity = max(0.0, min(shadowOpacity, 1.0))
            
            self.detailContainerView.layer.shadowOpacity = Float(shadowOpacity)
            self.detailContainerView.separatorAlpha = 1.0 - shadowOpacity
            let maskAlpha = detailRect.origin.x / sidebarWidth
            self.detailContainerView.coverMaskAlpha = maskAlpha
        }
    }
    
    // MARK: - 展开
    func shouldExpandAndUsingSpring(translation: CGPoint, velocity: CGPoint) -> (shouldExpand: Bool,
                                                                                 usingSpring: Bool) {
        let dx = translation.x
        let detailOriginX = self.detailContainerView.frame.minX

        var shouldExpand = false
        var usingSpring = false ///< 是否使用弹簧动画
        if (dx < 0) {
            if (sidebarWidth - detailOriginX > firstActiveTriggerDistance) {
                usingSpring = true
            } else {
                shouldExpand = (abs(velocity.x) > 750.0) ? false : true
            }
        } else {
            if (detailOriginX > firstActiveTriggerDistance) {
                shouldExpand = true
            } else {
                usingSpring = true
                if (velocity.x > 750.0) {
                    shouldExpand = true
                    usingSpring = false
                }
            }
        }
        
        return (shouldExpand, usingSpring)
    }
    
    
    func setExpand(_ shouldExpand: Bool, animated: Bool = true, forceLayout: Bool = true) {
        self.isExpand = shouldExpand
        
        let executeBlock = {
            if (shouldExpand) {
                self.disableDetailUserInteraction()
            } else {
                self.enableDetailUserInteraction()
            }
            
            if (forceLayout) {
                self.relayout()
            }
        }
        
        if (!animated) {
            executeBlock()
            return
        }

        /// 使用动画
        let usingSpring = !shouldExpand
        let dampingRatio = usingSpring ? 0.9 : 1.0
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: dampingRatio,
                       initialSpringVelocity: 6.0,
                       options: .curveEaseInOut,
                       animations: executeBlock,
                       completion: nil)
    }

    // MARK: - 切换新的详细视图控制器
    func replaceDetailViewController(_ detailViewController: UIViewController) {
        guard self.detailViewController != detailViewController else {
            return
        }
        
        self.removeSubViewController(self.detailViewController)
        self.detailViewController = detailViewController
        self.addSubviewController(detailViewController)
        self.detailContainerView.viewController = detailViewController
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.isExpand {
            return false
        }

        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if self.isExpand {
            return true
        }
        
        /// 侧边栏未展开状态
        let touchPoint = touch.location(in: self.view)
        guard touchPoint.x < 20.0 else {
            return false
        }
        
        var bShouldReceive = true
        var aView = touch.view
        while aView != nil {
            /// 触摸点在控件上
            if aView is UIControl {
                bShouldReceive = false
                break
            }
            
            aView = aView?.superview
        }

        return bShouldReceive
    }
    
    // MARK: - TPColumnContainerViewDelegate
    func columnContainerViewDidClickMask(_ containerView: TPColumnContainerView) {
        setExpand(false, animated: true)
    }
    
}
