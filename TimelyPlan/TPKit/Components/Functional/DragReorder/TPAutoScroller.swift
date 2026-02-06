//
//  TPAutoScroller.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/24.
//

import Foundation
import UIKit

protocol TPAutoScrollerDelegate: AnyObject {
    
    /// 自动滚动器刷新回调
    func autoScrollerDidRefresh(_ scroller: TPAutoScroller)
}

class TPAutoScroller {
    
    /// 代理对象
    weak var delegate: TPAutoScrollerDelegate?
    
    /// 自动滚动感应区域的高度
    var autoScrollDetectionLength: CGFloat = 60.0
    
    /// 最快滚动速度
    var autoScrollMaxVelocity: CGFloat = 15.0

    /// 滚动视图
    var scrollView: UIScrollView?
    
    /// 触摸信息
    private(set) var touchInfo: (point: CGPoint, view: UIView)?
    
    /// 自动滚动后如果触摸视图为滚动视图时触摸点信息会改变
    var touchPointDidChange: ((CGPoint) -> Void)?
    
    /// 自动滚动显示同步
    private var displayLink: CADisplayLink?
    
    /// 是否正在自动滚动中
    func isAutoScrolling() -> Bool {
        guard let displayLink = displayLink else {
            return false
        }

        return !displayLink.isPaused
    }
    
    /// 开始自动滚动
    func startAutoScroll() {
        stopAutoScroll()
        displayLink = CADisplayLink(target: self, selector: #selector(displayDidRefresh))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    /// 结束自动滚动
    func stopAutoScroll() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// 刷新显示
    @objc func displayDidRefresh() {
        if shouldStopAutoScroll() {
            stopAutoScroll()
            return
        }
    }
    
    /// 是否开始自动滚动
    func shouldStartAutoScroll() -> Bool {
        return false
    }
    
    /// 是否停止自动滚动
    func shouldStopAutoScroll() -> Bool {
        return true
    }
    
    func updateTouchInfo(_ touchInfo: (point: CGPoint, view: UIView)?) {
        self.touchInfo = touchInfo
        if shouldStartAutoScroll() {
            startAutoScroll()
        } else {
            stopAutoScroll()
        }
    }
}


class TPVerticalAutoScroller: TPAutoScroller {
    
    /// 滚动方向
    enum ScrollDirection: UInt {
        case none
        case up
        case down
    }

    ///自动滚动方向
    private var autoScrollDirection = ScrollDirection.none

    /// 是否开始自动滚动
    override func shouldStartAutoScroll() -> Bool {
        guard let scrollView = scrollView, let touchInfo = touchInfo else {
            return false
        }
        
        let convertedPoint = touchInfo.view.convert(touchInfo.point, toViewOrWindow: scrollView.superview)
        var shouldStart = false
        if convertedPoint.y < scrollView.frame.minY + autoScrollDetectionLength {
            autoScrollDirection = .down
            shouldStart = true
        } else {
            let insetBottom = max(scrollView.contentInset.bottom, scrollView.adjustedContentInset.bottom)
            if convertedPoint.y > scrollView.frame.maxY - insetBottom - autoScrollDetectionLength {
                autoScrollDirection = .up
                shouldStart = true
            }
        }
        
        if shouldStopAutoScroll() {
            shouldStart = false
        }
        
        return shouldStart
    }
    
    /// 是否停止自动滚动
    override func shouldStopAutoScroll() -> Bool {
        guard let scrollView = scrollView else {
            return true
        }
        
        if autoScrollDirection == .down {
            let insetTop = max(scrollView.contentInset.top, scrollView.adjustedContentInset.top)
            if scrollView.contentOffset.y <= -insetTop {
                /// 已经滚动到最顶部
                return true
            }
        }
        
        if autoScrollDirection == .up {
            let insetBottom = max(scrollView.contentInset.bottom, scrollView.adjustedContentInset.bottom)
            if scrollView.contentOffset.y + scrollView.bounds.size.height >= scrollView.contentSize.height + insetBottom {
                /// 已经滚动到最底部
                return true
            }
        }
        
        return false
    }
    
    override func displayDidRefresh() {
        super.displayDidRefresh()
        guard let scrollView = scrollView, let touchInfo = touchInfo else {
            return
        }
        
        let convertedPoint = touchInfo.view.convert(touchInfo.point, toViewOrWindow: scrollView.superview)
        var dy: CGFloat = 0
        switch autoScrollDirection {
        case .down:
            /// 触摸点在最上方
            dy = abs(scrollView.frame.minY + autoScrollDetectionLength - convertedPoint.y)
        case .up:
            /// 触摸点在最下方
            dy = abs(scrollView.frame.maxY - autoScrollDetectionLength - convertedPoint.y)
        default:
            break
        }
        
        var velocity = (dy / autoScrollDetectionLength) * autoScrollMaxVelocity
        velocity = min(velocity, autoScrollMaxVelocity)
        var movement = velocity
        if autoScrollDirection == .down {
            movement = -velocity
        }
        
        var offsetY = scrollView.contentOffset.y + movement
        offsetY = max(offsetY, -scrollView.adjustedContentInset.top)
        scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
        
        /// 当触摸视图为滚动视图时，通知触摸点信息改变
        if scrollView === touchInfo.view {
            let point = CGPoint(x: touchInfo.point.x, y: touchInfo.point.y + movement)
            touchPointDidChange?(point)
        }
        
        delegate?.autoScrollerDidRefresh(self)
    }
}

class TPHorizontalAutoScroller: TPAutoScroller {
    
    /// 滚动方向
    enum ScrollDirection: UInt {
        case none
        case left
        case right
    }

    ///自动滚动方向
    private var autoScrollDirection = ScrollDirection.none

    /// 是否开始自动滚动
    override func shouldStartAutoScroll() -> Bool {
        guard let scrollView = scrollView, let touchInfo = touchInfo else {
            return false
        }
        
        let convertedPoint = touchInfo.view.convert(touchInfo.point, toViewOrWindow: scrollView.superview)
        var shouldStart = false
        if convertedPoint.x < scrollView.frame.minX + autoScrollDetectionLength {
            autoScrollDirection = .right
            shouldStart = true
        } else if convertedPoint.x > scrollView.frame.maxX - autoScrollDetectionLength {
            autoScrollDirection = .left
            shouldStart = true
        }
        
        if shouldStopAutoScroll() {
            shouldStart = false
        }
        
        return shouldStart
    }
    
    /// 是否停止自动滚动
    override func shouldStopAutoScroll() -> Bool {
        guard let scrollView = scrollView else {
            return true
        }
        
        if autoScrollDirection == .right {
            let insetLeft = max(scrollView.contentInset.left, scrollView.adjustedContentInset.left)
            if scrollView.contentOffset.x <= -insetLeft {
                /// 已经滚动到最左部
                return true
            }
        }
        
        if autoScrollDirection == .left {
            let insetRight = max(scrollView.contentInset.right, scrollView.adjustedContentInset.right)
            if scrollView.contentOffset.x + scrollView.bounds.size.width >= scrollView.contentSize.width + insetRight {
                /// 已经滚动到最右部
                return true
            }
        }
        
        return false
    }

    override func displayDidRefresh() {
        super.displayDidRefresh()
        guard let scrollView = scrollView, let touchInfo = touchInfo else {
            return
        }
        
        let convertedPoint = touchInfo.view.convert(touchInfo.point, toViewOrWindow: scrollView.superview)
        var dx: CGFloat = 0
        switch autoScrollDirection {
        case .right:
            dx = abs(scrollView.frame.minX + autoScrollDetectionLength - convertedPoint.x)
        case .left:
            dx = abs(scrollView.frame.maxX - autoScrollDetectionLength - convertedPoint.x)
        default:
            break
        }
        
        var velocity = (dx / autoScrollDetectionLength) * autoScrollMaxVelocity
        velocity = min(velocity, autoScrollMaxVelocity)
        var movement = velocity
        if autoScrollDirection == .right {
            movement = -velocity
        }
        
        var offsetX = scrollView.contentOffset.x + movement
        offsetX = max(offsetX, -scrollView.adjustedContentInset.left)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0.0), animated: false)
        
        /// 当触摸视图为滚动视图时，通知触摸点信息改变
        if scrollView === touchInfo.view {
            let point = CGPoint(x: touchInfo.point.x + movement, y: touchInfo.point.y)
            touchPointDidChange?(point)
        }
        
        delegate?.autoScrollerDidRefresh(self)
    }
}
