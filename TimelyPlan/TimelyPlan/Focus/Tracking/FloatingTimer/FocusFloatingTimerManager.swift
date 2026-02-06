//
//  FocusFloatingTimerManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/17.
//

import Foundation
import UIKit

// 计时器位置
struct FocusFloatingTimerPosition: Codable {
    
    // 水平位置
    enum HorizontalPosition: Int, Codable {
        case right
        case left
    }
    
    // 水平位置
    var horizontal: HorizontalPosition = .right
    
    // 竖直相对位置，范围在 0 到 1 之间
    var vertical: CGFloat = 0.5
}

class FocusFloatingTimerManager: NSObject {

    /// 单例对象
    static let shared = FocusFloatingTimerManager()
    
    /// 边界间距
    private let edgeMargins = UIEdgeInsets(value: 5.0)

    /// 计时器尺寸
    private let trackingSize = CGSize(width: 60.0, height: 70.0)
    
    /// 浮动计时器追踪视图
    private var trackingView: FocusFloatingTrackingView?
    
    /// 计时器位置
    private var timerPosition = FocusFloatingTimerPosition()
    
    override init() {
        super.init()
    }
    
    // MARK: - 计算属性
    /// 计时器是否显示中
    var isDisplaying: Bool {
        guard let trackingView = trackingView, trackingView.superview != nil else {
            return false
        }

        return true
    }
    
    // MARK: - Public Methods
    /// 显示浮动计时器
    func showBubbleTimerView() {
        guard trackingView?.superview == nil, let window = UIWindow.keyWindow else {
            return
        }
        
        let trackingView = FocusFloatingTrackingView()
        self.trackingView = trackingView
        window.addSubview(trackingView)
        setupGesture(on: trackingView)
        layoutTimerView()
        trackingView.alpha = 0.0
        trackingView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut) {
            trackingView.transform = .identity
            trackingView.alpha = 1.0
        }
        
        /// 添加窗口尺寸变化通知
        addMainViewSizeChangeNotification()
    }
    
    func hideBubbleTimerView() {
        removeMainViewSizeChangeNotification()
        guard let trackingView = trackingView else {
            return
        }

        self.trackingView = nil
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut) {
            trackingView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            trackingView.alpha = 0.0
        } completion: { _ in
            trackingView.removeFromSuperview()
        }
    }
    
    // MARK: - 私有布局方法
    private func layoutTimerView() {
        guard let trackingView = trackingView, let superview = trackingView.superview else {
            return
        }
        
        let layoutFrame = superview.safeLayoutFrame().inset(by: edgeMargins)
        trackingView.size = trackingSize
        if timerPosition.horizontal == .left {
            trackingView.left = layoutFrame.minX
        } else {
            trackingView.right = layoutFrame.maxX
        }
        
        trackingView.centerY = layoutFrame.minY + trackingSize.height / 2.0 + ((layoutFrame.height - trackingSize.height) * timerPosition.vertical)
        if trackingView.top < layoutFrame.minY {
            trackingView.top = layoutFrame.minY
        }
        
        if trackingView.bottom > layoutFrame.maxY {
            trackingView.bottom = layoutFrame.maxY
        }
    }
    
    // MARK: - 手势操作
    private func setupGesture(on view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: view.superview)
        view.center = CGPoint(x: view.center.x + translation.x,
                              y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: view.superview)
        if gesture.state == .ended || gesture.state == .cancelled {
            self.snapToClosestEdge()
        }
    }

    @objc private func handleTap(_ gesture: UIPanGestureRecognizer) {
        TPImpactFeedback.impactWithSoftStyle()
        FocusTracker.shared.showTrackingViewControllerIfNeeded()
    }
    
    /// 计时器视图吸附到靠近的边
    private func snapToClosestEdge() {
        guard let trackingView = trackingView, let superview = trackingView.superview else {
            return
        }

        let layoutFrame = superview.safeLayoutFrame().inset(by: edgeMargins)
        let leftDistance = trackingView.center.x - layoutFrame.minX
        let rightDistance = layoutFrame.maxX - trackingView.center.x
        if leftDistance < rightDistance {
            self.timerPosition.horizontal = .left
            /// 吸附到左边
        } else {
            /// 吸附到右边
            self.timerPosition.horizontal = .right
        }
        
        self.timerPosition.vertical = vertical(of: trackingView.centerY, layoutFrame: layoutFrame)
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut) {
            self.layoutTimerView()
        }
    }
    
    // MARK: - 窗口尺寸变化通知
    private func addMainViewSizeChangeNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mainViewSizeDidChange),
                                               name: AppNotificationName.mainViewSizeDidChange.name,
                                               object: nil)
    }
    
    private func removeMainViewSizeChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func mainViewSizeDidChange(notification: Notification) {
        layoutTimerView()
    }
    
    // MARK: - Helpers
    /// 获取纵坐标位置
    private func vertical(of centerY: CGFloat, layoutFrame: CGRect) -> CGFloat {
        let minY = layoutFrame.minY + trackingSize.height / 2.0
        if centerY <= minY {
            return 0.0
        }
            
        let maxY = layoutFrame.maxY - trackingSize.height / 2.0
        if centerY >= maxY {
            return 1.0
        }
        
        return (centerY - minY) / (maxY - minY)
    }
}
