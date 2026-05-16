//
//  CalendarPageAutoScroller.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/20.
//

import Foundation
import UIKit

class CalendarPageAutoScroller {
    
    /// 时间间隔
    var interval = 0.25
    
    /// 自动滚动感应区域的宽度
    var autoScrollDetectionLength: CGFloat = 60.0
    
    /// 触摸信息
    private(set) var touchInfo: (point: CGPoint, view: UIView)?

    weak var pageView: CalendarWeekPageView?

    /// 计时器
    private var timer: Timer?
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    /// 开始自动滚动
    func startAutoScroll() {
        guard timer == nil else {
            return
        }
        
        // 创建 Timer
        timer = Timer(timeInterval: interval, repeats: true) {[weak self] _ in
            self?.timerUpdate()
        }
        
        // 将 Timer 添加到 RunLoop 的 .common mode
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    /// 结束自动滚动
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 计时器是否正在计时中
    func isRunning() -> Bool {
        return timer != nil
    }
    
    /// 是否开始自动滚动
    func shouldStartAutoScroll() -> Bool {
        let position = touchPosition()
        return position != .none
    }
    
    func updateTouchInfo(_ touchInfo: (point: CGPoint, view: UIView)?) {
        self.touchInfo = touchInfo
        if shouldStartAutoScroll() {
            startAutoScroll()
        } else {
            stopAutoScroll()
        }
    }
    
    private func timerUpdate() {
        guard let pageView = pageView, !pageView.isMoving else {
            return
        }

        let position = touchPosition()
        guard position != .none else {
            return
        }
        
        if position == .left {
            pageView.goPreviousDay()
        } else {
            pageView.goNextDay()
        }
    }
    
    // MARK: - Helpers
    private enum TouchPosition {
        case none
        case left
        case right
    }
    
    private func touchPosition() -> TouchPosition {
        guard let touchInfo = touchInfo else {
            return .none
        }
        
        if touchInfo.point.x <= autoScrollDetectionLength {
            return .left
        }
        
        if touchInfo.point.x >= (touchInfo.view.width - autoScrollDetectionLength) {
            return .right
        }
        
        return .none
    }
}
