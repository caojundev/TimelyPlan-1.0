//
//  CalendarPanelElementView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/29.
//

import Foundation
import UIKit

protocol CalendarPanelElementViewDelegate: AnyObject {
    
    func calendarPanelElementView(_ elementView: CalendarPanelElementView, didTapEvent event: CalendarEvent)
    
    func calendarPanelElementView(_ elementView: CalendarPanelElementView, didTapMoreOnDate date: Date)
    
    func calendarPanelElementView(_ elementView: CalendarPanelElementView, didTapDate date: Date)
    
    func calendarPanelElementView(_ elementView: CalendarPanelElementView, didLongPressDate date: Date)
}

/// 天元素视图：显示一天或多天，每一天对应一个天视图，下方显示事项
class CalendarPanelElementView: UIView, CalendarStripViewDelegate {
    
    /// 代理对象
    weak var delegate: CalendarPanelElementViewDelegate?
    
    /// 显示农历
    var showLunar: Bool = true {
        didSet {
            if showLunar != oldValue {
                reloadDayConfigs()
            }
        }
    }
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true {
        didSet {
            if showChineseHolidays != oldValue {
                reloadDayConfigs()
            }
        }
    }
    
    /// 显示的第一天
    private(set) var firstDay: Date?
    
    /// 显示的天数：1 为单天视图，大于 1 为多天视图
    private(set) var dayCount: Int = 1
    
    /// 该视图显示的所有天
    var days: [Date] {
        guard let firstDay = firstDay else {
            return []
        }
        
        return (0..<dayCount).compactMap { firstDay.dateByAddingDays($0) }
    }
    
    /// 头视图高度（日期区域）
    private let headerHeight = 32.0
    
    /// 事项视图
    private var eventsView: CalendarStripView?
    
    /// 天视图数组
    private var dayViews: [CalendarPanelDayView] = []
    
    /// 背景分割线图层
    private lazy var backgroundLayer: CalendarPanelElementBackgroundLayer = {
        let layer = CalendarPanelElementBackgroundLayer()
        return layer
    }()
    
    /// 事项数据（由页面统一加载后共享，避免每个天元素视图都请求一次）
    var events: [CalendarEvent]? {
        didSet {
            if events != oldValue {
                reloadEvents()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(backgroundLayer)
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        executeWithoutAnimation {
            self.backgroundLayer.frame = bounds
        }
        
        layoutDayViews()
        layoutEventsView()
    }
    
    // MARK: - Data
    
    /// 更新显示的天（第一天与天数由面板布局配置决定）
    func update(firstDay: Date?, dayCount: Int) {
        let firstDay = firstDay?.startOfDay()
        let dayCount = max(1, dayCount)
        
        /// 天数变化时天视图与事项视图的个数、横跨天数需要重建
        let needsRebuild = dayCount != self.dayCount || eventsView == nil
        self.firstDay = firstDay
        self.dayCount = dayCount
        
        if needsRebuild {
            setupDayViews()
            setupEventsView()
            setNeedsLayout()
        }
        
        if eventsView?.startDate != firstDay {
            eventsView?.startDate = firstDay
            eventsView?.reset()
        }
        
        reloadData()
    }
    
    /// 重新加载天配置与事项
    func reloadData() {
        reloadDayConfigs()
        reloadEvents()
        setNeedsLayout()
    }
    
    /// 根据显示天数创建 / 复用天视图
    private func setupDayViews() {
        if dayViews.count > dayCount {
            dayViews[dayCount...].forEach { $0.removeFromSuperview() }
            dayViews.removeLast(dayViews.count - dayCount)
        }
        
        while dayViews.count < dayCount {
            let dayView = CalendarPanelDayView()
            addSubview(dayView)
            dayViews.append(dayView)
        }
        
        backgroundLayer.dayCount = dayCount
    }
    
    /// 事项视图横跨的天数在创建时固定，天数变化时重建
    private func setupEventsView() {
        eventsView?.removeFromSuperview()
        
        let view = CalendarStripView(days: dayCount)
        view.delegate = self
        view.startDate = firstDay
        view.frame = eventsFrame
        addSubview(view)
        eventsView = view
    }
    
    // MARK: - Layout
    
    private func layoutDayViews() {
        let itemWidth = width / CGFloat(dayCount)
        for (index, dayView) in dayViews.enumerated() {
            let x = CGFloat(index) * itemWidth
            dayView.frame = CGRect(x: x, y: 0.0, width: itemWidth, height: headerHeight)
        }
    }
    
    private func layoutEventsView() {
        eventsView?.frame = eventsFrame
    }
    
    /// 事项区域（日期区域下方）
    private var eventsFrame: CGRect {
        let stripHeight = height - headerHeight
        return CGRect(x: 0.0, y: headerHeight, width: width, height: max(0.0, stripHeight))
    }
    
    // MARK: - Events
    
    /// 用页面共享的事项刷新事项视图
    /// 事项跨越本视图显示的天时由 CalendarStripLayoutProvider 按本视图的起始天与天数换算位置
    private func reloadEvents() {
        guard let events = events, !events.isEmpty else {
            eventsView?.reset()
            return
        }
        
        eventsView?.events = events
        eventsView?.reloadData()
    }
    
    // MARK: - Day Configs
    
    private func reloadDayConfigs() {
        guard let firstDay = firstDay else {
            dayViews.forEach { $0.reset() }
            return
        }
        
        let dayCount = self.dayCount
        let showLunar = self.showLunar
        let showChineseHolidays = self.showChineseHolidays
        
        loadDayConfigs(firstDay: firstDay,
                       dayCount: dayCount,
                       showLunar: showLunar,
                       showChineseHolidays: showChineseHolidays) { [weak self] dayConfigs in
            guard let self = self, self.firstDay == firstDay, self.dayCount == dayCount else {
                return
            }
            
            for i in 0..<min(dayConfigs.count, self.dayViews.count) {
                self.dayViews[i].update(with: dayConfigs[i])
            }
        }
    }
    
    private func loadDayConfigs(firstDay: Date,
                                dayCount: Int,
                                showLunar: Bool,
                                showChineseHolidays: Bool,
                                completion: @escaping ([CalendarMonthDayConfig]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var dayConfigs = [CalendarMonthDayConfig]()
            for i in 0..<dayCount {
                guard let date = firstDay.dateByAddingDays(i) else {
                    continue
                }
                
                let config = CalendarMonthDayConfig(date: date,
                                                    showLunar: showLunar,
                                                    showChineseHolidays: showChineseHolidays)
                dayConfigs.append(config)
            }
            
            DispatchQueue.main.async {
                completion(dayConfigs)
            }
        }
    }
    
    // MARK: - 手势
    
    /// 设置长按手势识别器
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.25
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.cancelsTouchesInView = false
        addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if let date = date(on: location) {
            delegate?.calendarPanelElementView(self, didTapDate: date)
        }
    }
    
    /// 处理长按手势
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: self)
            if let date = date(on: location) {
                delegate?.calendarPanelElementView(self, didLongPressDate: date)
            }
        }
    }
    
    // MARK: - Helpers
    
    /// 位置对应的日期（按显示天数均分宽度）
    private func date(on location: CGPoint) -> Date? {
        guard let firstDay = firstDay, dayCount > 0 else {
            return nil
        }
        
        let dayWidth = bounds.width / CGFloat(dayCount)
        guard dayWidth > 0 else {
            return nil
        }
        
        let index = min(max(Int(location.x / dayWidth), 0), dayCount - 1)
        return firstDay.dateByAddingDays(index)
    }
    
    // MARK: - CalendarStripViewDelegate
    func calendarStripView(_ view: CalendarStripView, didTapEvent event: CalendarEvent) {
        delegate?.calendarPanelElementView(self, didTapEvent: event)
    }
    
    func calendarStripView(_ view: CalendarStripView, didTapMoreOnDate date: Date) {
        delegate?.calendarPanelElementView(self, didTapMoreOnDate: date)
    }
}

/// 天元素视图的背景图层：绘制天之间的分隔线
class CalendarPanelElementBackgroundLayer: TPGridsLayer {
    
    /// 横跨天数（决定分隔线列数）
    var dayCount: Int = 1 {
        didSet {
            if dayCount != oldValue {
                updateLayoutStyle()
            }
        }
    }
    
    override init() {
        super.init()
        setupLayer()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayer() {
        updateLayoutStyle()
    }
    
    private func updateLayoutStyle() {
        var style = TPGridsLayoutStyle()
        style.rowsCount = 1
        style.fromRow = 0
        style.toRow = 1
        style.columsCount = max(1, dayCount)
        style.fromColum = 0
        style.toColum = dayCount - 1
        style.lineWidth = 0.4
        style.horizontalLineColor = Color(0x888888, 0.2)
        style.verticalLineColor = Color(0x888888, 0.2)
        self.layoutStyle = style
    }
}
