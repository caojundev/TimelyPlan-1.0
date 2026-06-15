//
//  CalendarDragDropManageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/15.
//

import Foundation
import UIKit

protocol CalendarDragDropManageViewDelegate: AnyObject {
    
    /// 结束编辑日期范围
    func dragDropManageView(_ view: CalendarDragDropManageView, didEndEditingDateRange dateRange: DateInterval)
}

class CalendarDragDropManageView: UIView,
                                  UIGestureRecognizerDelegate,
                                  CalendarScrollSynchronizable,
                                  TPAutoScrollerDelegate {
    
    weak var delegate: CalendarDragDropManageViewDelegate?
    
    /// 当前全天高度
    var allDayHeight: CGFloat = 0.0 {
        didSet {
            if allDayHeight != oldValue {
                contentView.contentInset = UIEdgeInsets(top: allDayHeight)
                updateMaskLayer()
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
    
    var layout = CalendarAxisLayout() {
        didSet {
            setNeedsLayout()
        }
    }
    
    // 内容视图
    private let contentView = UIScrollView()
    
    // 拖动模式
    private var dragMode: CalendarScheduleDragMode = .none
    
    // 相对中心点的位移
    private var touchOffset: CGPoint = .zero
    
    /// 垂直内容滚动器
    private var contentAutoScroller = TPVerticalAutoScroller()
    
    /// 水平页面滚动器
    private var pageAutoScroller = CalendarPageAutoScroller()
    
    /// 页面视图
    weak var pageView: CalendarPageView? {
        didSet {
            pageAutoScroller.pageView = pageView
            setNeedsLayout()
        }
    }
    
    /// 遮罩图层
    lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()
    
    // 作用事项
    private(set) var event: CalendarEvent?
    
    // 计划视图
    private let scheduleView: ScheduleDragView

    // 当前日期范围
    private var dateRange: DateInterval
    
    /// 当前天
    private var dayDate: Date
    
    var columnEdgeMargin: CGFloat = 2.0
    
    // 属性
    var minHeight: CGFloat {
        return CalendarConstant.minimumTimedEventViewHeight
    }

    private var panGesture: UIPanGestureRecognizer?
    
    init(dateRange: DateInterval) {
        self.dateRange = dateRange
        self.dayDate = dateRange.start
        self.scheduleView = CalendarScheduleDragAddView(dateRange: dateRange)
        super.init(frame: .zero)
        commonInit()
    }

    init(event: CalendarEvent) {
        self.event = event
        self.dateRange = event.dateRange
        self.dayDate = dateRange.start
        self.scheduleView = CalendarScheduleDragEventView(event: event)
        super.init(frame: .zero)
        commonInit()
    }

    private func commonInit() {
        self.layer.mask = maskLayer
        setupContentView()
        setupGesture()
        setupAutoScroller()
    }
    
    private func setupContentView() {
        backgroundColor = .clear
        isMultipleTouchEnabled = false
        contentView.contentInsetAdjustmentBehavior = .never
        contentView.scrollsToTop = false
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.contentSize = CGSize(width: bounds.width,
                                         height: layout.contentHeight)
        addSubview(contentView)
        
        /// 添加计划视图
        contentView.addSubview(scheduleView)
    }
    
    private func setupAutoScroller() {
        pageAutoScroller.interval = 0.4
        pageAutoScroller.autoScrollDetectionLength = 40.0
        
        contentAutoScroller.scrollView = contentView
        contentAutoScroller.autoScrollDetectionLength = 60.0
        contentAutoScroller.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        contentView.contentSize = CGSize(width: bounds.width,
                                         height: layout.contentHeight)
        updateMaskLayer()
        updateScheduleViewFrame()
        highlightDateRange()
    }
    
    func dismiss() {
        delegate = nil
        panGesture?.isEnabled = false
        removeFromSuperview()
    }

    // MARK: - 响应者链
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == contentView {
            let collectionView = pageView?.collectionView
            let collectionPoint = convert(point, toViewOrWindow: collectionView)
            return collectionView?.hitTest(collectionPoint, with: event)
        }
        
        return hitView
    }
    
    // MARK: - Update
    private func updateMaskLayer() {
        let frame = CGRect(x: 0.0,
                           y: allDayHeight,
                           width: bounds.width,
                           height: bounds.height - allDayHeight)
        let path = UIBezierPath(rect: frame)
        self.maskLayer.path = path.cgPath
    }
    
    private func updateScheduleViewFrame() {
        guard let pageView = pageView else {
            return
        }

        let column = pageView.column(of: dayDate)
        var frame = layout.frame(of: dateRange, minHeight: minHeight)
        frame.size.width = columnWidth -  2 * columnEdgeMargin
        frame.origin.x = CGFloat(column) * columnWidth + columnEdgeMargin
        scheduleView.frame = frame
    }
    
    private func updateDayDate() {
        guard let pageView = pageView else {
            return
        }

        let column = snappedColumn(of: scheduleView.center)
        self.dayDate = pageView.date(of: column)
    }
    
    /// 更新日期范围
    private func updateDateRange() {
        let snappedFrame = snappedFrame(of: scheduleView.frame)
        dateRange = layout.dateRange(of: snappedFrame)
        scheduleView.dateRange = dateRange
    }
    
    private func highlightDateRange() {
        guard let pageView = pageView else {
            return
        }

        pageView.highlightDateRange(dateRange)
    }
    
    private func updateAndHighlightDateRange() {
        updateDateRange()
        highlightDateRange()
    }
    
    // MARK: - Gesture Handling
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        self.panGesture = panGesture
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(_:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        var dateRange = self.dateRange
        dateRange.replacingDay(with: dayDate)
        delegate?.dragDropManageView(self, didEndEditingDateRange: dateRange)
    }
    
    private func panBegan(with touchPoint: CGPoint) {
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
        
        if dragMode != .none {
            pageView?.dragDropPanBegan()
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
            originY = max(originY, layout.topMargin)
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
        updateAndHighlightDateRange()
    }
    
    private func panEnded(with touchPoint: CGPoint) {
        pageAutoScroller.stopAutoScroll()
        contentAutoScroller.stopAutoScroll()
        pageView?.dragDropPanEnded()
        guard self.dragMode != .none else {
            return
        }
        
        updateDayDate()
        updateAndHighlightDateRange()
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
        let snappedFrame = snappedFrame(of: scheduleView.frame)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.scheduleView.frame = snappedFrame
        }
        
        updateAndHighlightDateRange()
    }

    private func snappedFrame(of rect: CGRect) -> CGRect {
        var frame = rect
        let snappedX = snappedX(of: rect.center)
        frame.origin.x = snappedX
        frame.size.width = columnWidth - 2 * columnEdgeMargin
        return layout.snappedFrame(of: frame, minHeight: minHeight)
    }
    
    // MARK: - 水平位置
    private func snappedX(of point: CGPoint) -> CGFloat {
        let column = snappedColumn(of: point)
        return CGFloat(column) * columnWidth + columnEdgeMargin
    }
    
    private func snappedColumn(of point: CGPoint) -> Int {
        let columnWidth = columnWidth
        guard columnWidth > 0 else {
            return 0
        }
        
        let column = Int(point.x / columnWidth)
        var maxColumn = Int(round(bounds.width / columnWidth)) - 1
        maxColumn = max(0, maxColumn)
        return clampedValue(column, 0, maxColumn)
    }
    
    private var columnWidth: CGFloat {
        guard let pageView = pageView else {
            return 0.0
        }

        return pageView.dayWidth
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
        return true
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
