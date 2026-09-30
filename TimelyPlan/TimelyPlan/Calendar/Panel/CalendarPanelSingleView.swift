//
//  CalendarPanelSingleView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/29.
//

import Foundation
import UIKit

protocol CalendarPanelSingleViewDelegate: AnyObject {
    
    /// 点击事项
    func calendarPanelSingleView(_ singleView: CalendarPanelSingleView, didTapEvent event: CalendarEvent)
    
    /// 点击更多
    func calendarPanelSingleView(_ singleView: CalendarPanelSingleView, didTapMoreOnDate date: Date)
    
    /// 点击日期
    func calendarPanelSingleView(_ singleView: CalendarPanelSingleView, didTapDate date: Date)
    
    /// 长按日期
    func calendarPanelSingleView(_ singleView: CalendarPanelSingleView, didLongPressDate date: Date)
}

/// 面板的一个页面：按样式创建天元素视图，并交给布局对象计算位置
class CalendarPanelSingleView: UIView {
    
    /// 代理对象
    weak var delegate: CalendarPanelSingleViewDelegate?
    
    /// 页面显示的第一天
    var firstDay: Date? {
        didSet {
            guard firstDay != oldValue else {
                return
            }
            
            reloadDayData()
            loadEvents()
            reloadWidgets()
        }
    }
    
    /// 周开始日（挂件等使用）
    var firstWeekday: Weekday = .sunday {
        didSet {
            if firstWeekday != oldValue {
                reloadWidgets()
            }
        }
    }
    
    /// 面板布局样式：决定页面中天元素视图的个数、每个视图显示的天数及其位置
    var panelStyle: CalendarPanelStyle {
        get {
            return layout.style
        }
        
        set {
            guard newValue != layout.style else {
                return
            }
            layout.style = newValue
            reloadData()
        }
    }
    
    /// 显示农历
    var showLunar: Bool = true {
        didSet {
            if showLunar != oldValue {
                elementViews.forEach { $0.showLunar = showLunar }
            }
        }
    }
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true {
        didSet {
            if showChineseHolidays != oldValue {
                elementViews.forEach { $0.showChineseHolidays = showChineseHolidays }
            }
        }
    }
    
    /// 布局对象：负责所有位置计算
    private let layout: CalendarPanelLayout
    
    /// 事项供应者：按页面（一周）加载事项，页面中的所有天元素视图共享该数据
    private let eventsViewModel = CalendarEventsViewModel()
    
    /// 当前页面中的天元素视图
    private var elementViews: [CalendarPanelElementView] = []
    
    /// 根据样式创建页面视图
    init(style: CalendarPanelStyle) {
        self.layout = CalendarPanelLayout(style: style)
        super.init(frame: .zero)
        setupViews()
    }
    
    override init(frame: CGRect) {
        self.layout = CalendarPanelLayout()
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
        eventsViewModel.onEventsChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.reloadEvents()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutElementViews()
    }
    
    // MARK: - Data
    
    func reloadData() {
        reloadElementViews()
        reloadDayData()
        loadEvents()
        reloadWidgets()
        setNeedsLayout()
    }
    
    /// 刷新挂件（非天元素视图，子类可重写）
    func reloadWidgets() {
    }
    
    /// 挂件位置：由布局对象按样式的挂件配置计算
    func widgetFrame(at index: Int) -> CGRect? {
        return layout.widgetFrame(at: index, in: bounds)
    }
    
    /// 根据样式创建 / 复用天元素视图（个数是动态的）
    private func reloadElementViews() {
        let itemCount = layout.numberOfDayItems
        
        if elementViews.count > itemCount {
            elementViews[itemCount...].forEach { $0.removeFromSuperview() }
            elementViews.removeLast(elementViews.count - itemCount)
        }
        
        while elementViews.count < itemCount {
            let elementView = CalendarPanelElementView()
            elementView.delegate = self
            elementView.showLunar = showLunar
            elementView.showChineseHolidays = showChineseHolidays
            addSubview(elementView)
            elementViews.append(elementView)
        }
    }
    
    /// 刷新每个天元素视图显示的天（一天或多天）
    private func reloadDayData() {
        // 天元素视图个数与样式不一致时先同步视图
        if elementViews.count != layout.numberOfDayItems {
            reloadElementViews()
        }
        
        let firstDay = self.firstDay?.startOfDay()
        for (index, item) in layout.config.dayItems.enumerated() {
            guard index < elementViews.count else {
                break
            }
            
            let elementView = elementViews[index]
            elementView.update(firstDay: firstDay?.dateByAddingDays(item.dayOffset),
                               dayCount: item.dayCount)
        }
    }
    
    /// 加载页面事项：一次请求即可，所有天元素视图共享
    private func loadEvents() {
        guard let firstDay = firstDay else {
            return
        }
        
        /// 按页面显示的总天数加载（通常为一周，样式可能展示超过一周）
        let dayCount = max(DAYS_PER_WEEK, layout.daysInPage)
        let range = DateInterval.rangeOfDays(firstDate: firstDay, dayCount: dayCount)
        
        /// 区间未变直接使用已加载的事项
        if eventsViewModel.range == range {
            reloadEvents()
            return
        }
        
        /// 区间变化时先清空，避免元素视图显示上一页面的事项
        elementViews.forEach { $0.events = nil }
        eventsViewModel.loadEvents(in: range)
    }
    
    /// 把共享的事项分发给各天元素视图
    private func reloadEvents() {
        let events = eventsViewModel.events
        for elementView in elementViews {
            elementView.events = events
        }
    }
    
    /// 应用布局对象计算出的位置
    private func layoutElementViews() {
        let itemLayouts = layout.dayItemLayouts(in: bounds)
        for (index, itemLayout) in itemLayouts.enumerated() {
            guard index < elementViews.count else {
                break
            }
            elementViews[index].frame = itemLayout.frame
        }
    }
}

// MARK: - CalendarPanelElementViewDelegate
extension CalendarPanelSingleView: CalendarPanelElementViewDelegate {
    
    func calendarPanelElementView(_ elementView: CalendarPanelElementView, didTapEvent event: CalendarEvent) {
        delegate?.calendarPanelSingleView(self, didTapEvent: event)
    }
    
    func calendarPanelElementView(_ elementView: CalendarPanelElementView, didTapMoreOnDate date: Date) {
        delegate?.calendarPanelSingleView(self, didTapMoreOnDate: date)
    }
    
    func calendarPanelElementView(_ elementView: CalendarPanelElementView, didTapDate date: Date) {
        delegate?.calendarPanelSingleView(self, didTapDate: date)
    }
    
    func calendarPanelElementView(_ elementView: CalendarPanelElementView, didLongPressDate date: Date) {
        delegate?.calendarPanelSingleView(self, didLongPressDate: date)
    }
}
