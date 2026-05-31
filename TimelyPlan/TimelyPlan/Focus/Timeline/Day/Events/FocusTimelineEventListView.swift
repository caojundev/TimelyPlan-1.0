//
//  FocusTimelineEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation
import UIKit

/// 时间线事件列表视图点击代理协议
protocol FocusTimelineEventListTapDelegate: AnyObject {
    /// 当用户点击时间线事件时调用
    /// - Parameter event: 被点击的时间线事件
    func didTapTimelineEvent(_ event: FocusTimelineEvent)
}

class FocusTimelineEventListView: UIView, UIGestureRecognizerDelegate {

    /// 点击事件代理
    weak var tapDelegate: FocusTimelineEventListTapDelegate?
    
    var hourHeight: CGFloat = 80.0 {
        didSet {
            if hourHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 当前时间线所在日期
    var date: Date = .now {
        didSet {
            self.dateRange = .timelineRangeOfDay(date)
        }
    }
    
    var events: [FocusTimelineEvent]?

    private var eventViews: [FocusTimelineEventView] = []

    private var layout: FocusTimelineLayout?
    
    private let contentView = UIView()

    /// 时间线日期范围
    private lazy var dateRange: DateInterval = {
        return .timelineRangeOfDay(date)
    }()
    
    /// 顶部内边距
    var topPadding: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        setupLongPressGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        contentView.frame = CGRect(x: layoutFrame.minX,
                                   y: layoutFrame.minY,
                                   width: layoutFrame.width,
                                   height: layoutFrame.height + hourHeight)
        guard let layout = layout else {
            return
        }

        layout.containerSize = layoutFrame.size
        for eventView in eventViews {
            eventView.frame = layout.frame(for: eventView.event)
        }
    }
    
    private func setupEventViews() {
        eventViews.forEach { $0.removeFromSuperview() }
        eventViews.removeAll()
        guard let events = events else {
            return
        }

        var eventViews = [FocusTimelineEventView]()
        for event in events {
            let eventView = FocusTimelineEventView(event: event)
            eventView.tapDelegate = self
            contentView.addSubview(eventView)
            eventViews.append(eventView)
        }
        
        self.eventViews = eventViews
        self.setNeedsLayout() /// 重新布局
    }
    
    func clear() {
        events = nil
        layout = nil
        setupEventViews()
    }
    
    func reloadData() {
        self.layout = FocusTimelineLayout(events: self.events, dateRange: self.dateRange)
        self.setupEventViews()
    }
    
    /// 设置长按手势识别器
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.25
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(longPressGesture)
    }
    
    /// 处理长按手势
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        var location = gesture.location(in: self)
        location = self.convert(location, toViewOrWindow: contentView)
        
        // 检查触摸点是否在已有事件视图上
        if FocusTimelineTimeUtils.isPointOnEventView(location, eventViews: eventViews) {
            return // 在已有事件上不执行添加操作
        }
        
        // 执行添加操作
        performAddOperation(at: location)
    }
    
    /// 执行添加操作
    private func performAddOperation(at location: CGPoint) {
        // 将触摸点Y坐标转换为时间
        let viewHeight = layoutFrame().height
        let rawTime = FocusTimelineTimeUtils.time(fromY: location.y,
                                                  dateRange: dateRange,
                                                  viewHeight: viewHeight)
        
        // 对齐粒度
        let alignedStartTime = FocusTimelineTimeUtils.alignTime(rawTime)
        let endTime = FocusTimelineTimeUtils.endTime(from: alignedStartTime)
        
        // 计算指示视图的位置和大小
        let startY = FocusTimelineTimeUtils.y(fromTime: alignedStartTime,
                                              dateRange: dateRange,
                                              viewHeight: viewHeight)
        let indicatorHeight = FocusTimelineTimeUtils.heightForDuration(FocusTimelineTimeUtils.defaultFocusDuration,
                                                                       dateRange: dateRange,
                                                                       viewHeight: viewHeight)
        
        let indicatorFrame = CGRect(x: 0.0, y: startY, width: contentView.width, height: indicatorHeight)
        // 显示指示视图
        let _ = FocusTimelineAddIndicatorView.showIndicator(in: contentView,
                                                            frame: indicatorFrame,
                                                            duration: 0.8)
        
        // 创建新的专注记录
        createFocusRecord(startTime: alignedStartTime, endTime: endTime)
    }
    
    /// 创建新的专注记录
    private func createFocusRecord(startTime: Date, endTime: Date) {
        TPImpactFeedback.impactWithSoftStyle()
        FocusPresenter.createRecord(startTime: startTime, endTime: endTime)
    }
    
}

// MARK: - FocusTimelineEventTapDelegate
extension FocusTimelineEventListView: FocusTimelineEventTapDelegate {
    func didTapTimelineEvent(_ event: FocusTimelineEvent) {
        tapDelegate?.didTapTimelineEvent(event)
    }
}
