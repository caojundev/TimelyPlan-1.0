//
//  CalendarDragDropManageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/15.
//

import Foundation
import UIKit

class CalendarDragDropManageView: UIView,
                                  UIGestureRecognizerDelegate,
                                  CalendarScrollSynchronizable,
                                  TPAutoScrollerDelegate {

    let snapGridMinutes: Int = 10
    
    var columns: Int = 3
    
    var columnEdgeMargin: CGFloat = 5.0
    
    // 属性
    var minHeight: CGFloat = 20
    
    // 小时高度
    var hourHeight: CGFloat = 80.0 {
        didSet {
            if hourHeight != oldValue {
                setNeedsLayout()
            }
        }
    }

    /// 当前全天高度
    var allDayHeight: CGFloat = 0.0 {
        didSet {
            if allDayHeight != oldValue {
                contentView.contentInset = UIEdgeInsets(bottom: allDayHeight)
            }
        }
    }
    
    var contentOffset: CGPoint {
        get {
            return contentView.contentOffset
        }
        
        set {
            contentView.contentOffset = newValue
        }
    }
    
    /// 滚动视图代理
    var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return contentView.delegate
        }
        
        set {
            contentView.delegate = newValue
        }
    }
    
    // 顶部间距
    private let topPadding: CGFloat = 20
    
    // 底部间距
    private let bottomPadding: CGFloat = 20
    
    // 内容视图
    private let contentView = UIScrollView()
    
    // 拖动模式
    private let scheduleView = ScheduleDragView()
    
    // 拖动模式
    private var dragMode: CalendarScheduleDragMode = .none
    
    // 相对中心点的位移
    private var touchOffset: CGPoint = .zero
    
    /// 垂直内容滚动器
    private var contentAutoScroller = TPVerticalAutoScroller()
    
    /// 水平页面滚动器
    private var pageAutoScroller = CalendarPageAutoScroller()
    
    private weak var pageView: CalendarWeekPageView?
    
    init(pageView: CalendarWeekPageView) {
        self.pageView = pageView
        super.init(frame: .zero)
        setupContentView()
        setupGesture()
        setupAutoScroller()
        pageView.synchronizer.addSynchronizableView(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        updateContentSize()

        scheduleView.frame = CGRect(x: 60, y: 100, width: 180.0, height: 180)
        performSnapAnimation()
    }
    
    private func setupAutoScroller() {
        pageAutoScroller.pageView = pageView
        pageAutoScroller.interval = 0.25
        pageAutoScroller.autoScrollDetectionLength = 40.0
        
        contentAutoScroller.scrollView = contentView
        contentAutoScroller.autoScrollDetectionLength = 60.0
        contentAutoScroller.delegate = self
    }
    
    private func setupContentView() {
        backgroundColor = .orangePrimary.withAlphaComponent(0.6)
        contentView.scrollsToTop = false
        contentView.showsVerticalScrollIndicator = true
        contentView.showsHorizontalScrollIndicator = false
        addSubview(contentView)
        updateContentSize()
        contentView.addSubview(scheduleView)
    }
    
    private func updateContentSize() {
        let contentHeight = hourHeight * CGFloat(HOURS_PER_DAY) + topPadding + bottomPadding
        contentView.contentSize = CGSize(width: bounds.width, height: contentHeight)
    }
    
    // MARK: - Gesture Handling
    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
    }
    
    private func panBegan(with touchPoint: CGPoint) {
        let startDate = Date()
        let endDate = startDate.dateByAddingMinutes(20)
        let dateRange = DateRange(startDate: startDate, endDate: endDate)
        pageView?.highlightDateRange(dateRange)
        
        
        dragMode = dragMode(at: touchPoint)
        let point = convert(touchPoint, toViewOrWindow: scheduleView)
        switch dragMode {
        case .none:
            break
        case .move:
            touchOffset = CGPoint(
                x: point.x - scheduleView.bounds.midX,
                y: point.y - scheduleView.bounds.midY
            )
        case .resizeTopRight:
            let topRightHandleCenter = scheduleView.topRightHandleCenter
            touchOffset = CGPoint(
                x: point.x - topRightHandleCenter.x,
                y: point.y - topRightHandleCenter.y
            )
        case .resizeBottomLeft:
            let bottomLeftHandleCenter = scheduleView.bottomLeftHandleCenter
            touchOffset = CGPoint(
                x: point.x - bottomLeftHandleCenter.x,
                y: point.y - bottomLeftHandleCenter.y
            )
        }
    }
    
    private func panChanged(with touchPoint: CGPoint) {
        var shouldUpdateAutoScroller: Bool = true
        let contentPoint = convert(touchPoint, toViewOrWindow: contentView)
        switch dragMode {
        case .none:
            shouldUpdateAutoScroller = false
        case .move:
            scheduleView.center = CGPoint(
                x: contentPoint.x - touchOffset.x,
                y: contentPoint.y - touchOffset.y
            )
        case .resizeTopRight:
            var frame = scheduleView.frame
            var originY = contentPoint.y - touchOffset.y
            originY = max(originY, topPadding)
            let maxY = frame.maxY - minHeight
            if originY > maxY {
                originY = maxY
                shouldUpdateAutoScroller = false
            }
            
            let height = frame.maxY - originY
            frame.origin.y = originY
            frame.size.height = height
            scheduleView.frame = frame
        case .resizeBottomLeft:
            var frame = scheduleView.frame
            var height = contentPoint.y - scheduleView.frame.minY - touchOffset.y
            if height < minHeight {
                height = minHeight
                shouldUpdateAutoScroller = false
            }
            
            frame.size.height = height
            scheduleView.frame = frame
        }
        
        guard shouldUpdateAutoScroller else {
            return
        }
        
        let touchInfo = (touchPoint, self)
        if dragMode == .move {
            /// 仅移动模式下允许翻页
            pageAutoScroller.updateTouchInfo(touchInfo)
        }
        
        contentAutoScroller.updateTouchInfo(touchInfo)
    }
    
    private func panEnded(with touchPoint: CGPoint) {
        pageView?.clearHighlight()
        pageAutoScroller.stopAutoScroll()
        contentAutoScroller.stopAutoScroll()
        guard self.dragMode != .none else {
            return
        }
        
        performSnapAnimation()
        dragMode = .none
        touchOffset = .zero
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        switch gesture.state {
        case .began:
            panBegan(with: touchPoint)
        case .changed:
            panChanged(with: touchPoint)
        default:
            panEnded(with: touchPoint)
        }
    }
    
    // MARK: - 吸附逻辑
    private func performSnapAnimation() {
        let gridUnit = CGFloat(snapGridMinutes) / CGFloat(MINUTES_PER_HOUR) * hourHeight
        let rect = scheduleView.frame
        let snappedX = snappedX(of: rect.center)
        let snappedWidth = width / CGFloat(columns) - 2 * columnEdgeMargin
        
        var snappedY = topPadding + round((rect.minY - topPadding) / gridUnit) * gridUnit
        var snappedHeight = round(rect.height / gridUnit) * gridUnit
        
        // 防止吸附后太小
        if snappedHeight < minHeight {
            snappedHeight = minHeight
        }
        
        // 防止吸附后超出屏幕下方
        let maxY = contentView.contentSize.height - bottomPadding
        if snappedY + snappedHeight > maxY {
            snappedY = maxY - snappedHeight
        }
        
        if snappedY < topPadding {
            snappedY = topPadding
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.scheduleView.frame = CGRect(x: snappedX,
                                             y: snappedY,
                                             width: snappedWidth,
                                             height: snappedHeight)
        }
    }
    
    private func snappedX(of point: CGPoint) -> CGFloat {
        let column = snappedColumn(of: point)
        let columnWidth = bounds.width / CGFloat(columns)
        return CGFloat(column) * columnWidth + columnEdgeMargin
    }
    
    private func snappedColumn(of point: CGPoint) -> Int {
        let columnWidth = bounds.width / CGFloat(columns)
        guard columnWidth > 0 else {
            return 0
        }
        
        let column = Int(point.x / columnWidth)
        return clampedValue(column, 0, columns - 1)
    }
    
    
    // MARK: - Helpers
    private func dragMode(at touchPoint: CGPoint) -> CalendarScheduleDragMode {
        let point = convert(touchPoint, toViewOrWindow: scheduleView)
        return scheduleView.dragMode(touchPoint: point)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: self)
        return dragMode(at: touchPoint) != .none
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    // MARK: - TPAutoScrollerDelegate
    func autoScrollerDidRefresh(_ scroller: TPAutoScroller) {
        guard let touchInfo = scroller.touchInfo else {
            return
        }
        
        panChanged(with: touchInfo.point)
    }
}
