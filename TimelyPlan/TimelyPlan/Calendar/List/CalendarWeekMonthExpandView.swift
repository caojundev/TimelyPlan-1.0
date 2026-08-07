//
//  CalendarWeekMonthExpandView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/7.
//

import Foundation
import UIKit

protocol CalendarWeekMonthExpandViewDelegate: AnyObject {
    
    func calendarWeekMonthExpandView(_ view: CalendarWeekMonthExpandView, didSelectDate dateComponents: DateComponents)
    
    func calendarWeekMonthExpandView(_ view: CalendarWeekMonthExpandView, didChangeVisibleDate dateComponents: DateComponents)
    
    func calendarWeekMonthExpandViewFrameChanged(_ view: CalendarWeekMonthExpandView)
}

class CalendarWeekMonthExpandView: UIView, TPMidnightUpdatable {
    
    weak var delegate: CalendarWeekMonthExpandViewDelegate?
    
    /// 选中日期自动切换到周视图
    var autoSwitchToWeekOnSelectDate: Bool = false
    
    var weekContentHeight: CGFloat {
        return weekdaySymbolHeight + weekHeight + containerView.grabberHeight
    }
    
    var progress: CGFloat {
        return containerView.progress
    }
    
    // MARK: - 常量配置
    /// 星期栏高度
    private let weekdaySymbolHeight: CGFloat = 20.0
    
    /// 单行周视图高度
    private let weekHeight: CGFloat = 60.0
    
    /// 月视图总高度（6行）
    private var monthViewHeight: CGFloat {
        return 6.0 * weekHeight
    }

    // MARK: - 子视图
    /// 顶部星期栏（固定不参与展开动画）
    private lazy var weekdaySymbolView: TPWeekdaySymbolView = {
        let view = TPWeekdaySymbolView(frame: .zero,
                                       style: .short,
                                       firstWeekday: firstWeekday)
        view.backgroundColor = .systemBackground
        view.addSeparator(position: .bottom)
        return view
    }()

    /// 周月切换容器（仅负责手势+动画+子视图管理）
    private var containerView: CalendarExpandContainerView!
    
    // MARK: - 业务组件
    /// 日期选择管理器（周/月视图共用，保证选中状态同步）
    private lazy var selection: TPCalendarSingleDateSelection = {
        let selection = TPCalendarSingleDateSelection()
        selection.delegate = self
        selection.setSelectedDateComponents(visibleDateComponents)
        return selection
    }()

    /// 周开始日
    private(set) var firstWeekday: Weekday

    /// 可见日期组件
    private(set) var visibleDateComponents: DateComponents
    
    private(set) var showLunar: Bool
    
    private(set) var showChineseHolidays: Bool
    
    private(set) var eventsInfoFetcher: CalendarRangeEventsProvider?
    
    // MARK: - 初始化
    init(frame: CGRect,
         mode: CalendarExpandMode,
         firstWeekday: Weekday,
         visibleDateComponents: DateComponents,
         showLunar: Bool = true,
         showChineseHolidays: Bool = true,
         eventsInfoFetcher: CalendarRangeEventsProvider? = nil) {
        self.firstWeekday = firstWeekday
        self.visibleDateComponents = visibleDateComponents
        self.showLunar = showLunar
        self.showChineseHolidays = showChineseHolidays
        self.eventsInfoFetcher = eventsInfoFetcher
        super.init(frame: frame)
        self.containerView = CalendarExpandContainerView(initialMode: mode)
        self.containerView.delegate = self
        setupViews()
        TPMidnightScheduler.shared.addUpdater(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 视图搭建
    private func setupViews() {
        addSubview(weekdaySymbolView)
        addSubview(containerView)
        // 加载初始模式对应的视图
        containerView.loadInitialView()
    }

    // MARK: - 手动布局
    override func layoutSubviews() {
        super.layoutSubviews()

        // 星期栏固定顶部
        weekdaySymbolView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: weekdaySymbolHeight
        )

        // 切换容器紧跟星期栏，宽度与父视图对齐，高度由容器自身管理（手势/动画驱动）
        containerView.frame = CGRect(
            x: 0,
            y: weekdaySymbolHeight,
            width: bounds.width,
            height: containerView.height
        )
    }
    
    var contentHeight: CGFloat {
        return weekdaySymbolHeight + containerView.height
    }

    // MARK: - 对外公共方法
    
    // 设置周开始日
    func setFirstWeekday(_ firstWeekday: Weekday) {
        guard self.firstWeekday != firstWeekday else {
            return
        }

        self.firstWeekday = firstWeekday
        weekdaySymbolView.setFirstWeekday(firstWeekday)
        
        let currentView = containerView.currentView
        if let monthView = currentView as? CalendarExpandMonthView {
            monthView.firstWeekday = firstWeekday
            monthView.reloadData()
        } else if let weekView = currentView as? CalendarExpandWeekView {
            weekView.firstWeekday = firstWeekday
            weekView.reloadData()
        }
    }
    
    func setShowLunar(_ showLunar: Bool) {
        guard self.showLunar != showLunar else {
            return
        }
        
        self.showLunar = showLunar
        let currentView = containerView.currentView
        if let monthView = currentView as? CalendarExpandMonthView {
            monthView.showLunar = showLunar
            monthView.reloadData()
        } else if let weekView = currentView as? CalendarExpandWeekView {
            weekView.showLunar = showLunar
            weekView.reloadData()
        }
    }
    
    func setShowChineseHolidays(_ showChineseHolidays: Bool) {
        guard self.showChineseHolidays != showChineseHolidays else {
            return
        }
        
        self.showChineseHolidays = showChineseHolidays
        let currentView = containerView.currentView
        if let monthView = currentView as? CalendarExpandMonthView {
            monthView.showChineseHolidays = showChineseHolidays
            monthView.reloadData()
        } else if let weekView = currentView as? CalendarExpandWeekView {
            weekView.showChineseHolidays = showChineseHolidays
            weekView.reloadData()
        }
    }

    func setVisibleDateComponents(_ visibleDateComponents: DateComponents, animated: Bool = true ) {
        guard self.visibleDateComponents != visibleDateComponents else {
            return
        }
        
        self.visibleDateComponents = visibleDateComponents
        let currentView = containerView.currentView
        if let monthView = currentView as? CalendarExpandMonthView {
            monthView.setVisibleDateComponents(visibleDateComponents, animated: animated)
        } else if let weekView = currentView as? CalendarExpandWeekView {
            weekView.setVisibleDateComponents(visibleDateComponents, animated: animated)
        }
    }
    
    func setSelectedDate(_ date: Date) {
        let dateComponents = date.yearMonthDayComponents
        selection.setSelectedDateComponents(dateComponents)
        setVisibleDateComponents(dateComponents, animated: true)
    }
    
    /// 外部手动切换周/月模式
    func switchMode(_ mode: CalendarExpandMode, animated: Bool) {
        containerView.switchToMode(mode, animated: animated)
    }

    // MARK: - 私有方法
    private func changeVisibleDateComponents(_ dateComponents: DateComponents) {
        if containerView.currentMode == .month,
           let selectedDate = selection.selectedDate,
           selectedDate.isInSameMonth(as: dateComponents) {
            self.visibleDateComponents = selectedDate
            delegate?.calendarWeekMonthExpandView(self, didChangeVisibleDate: selectedDate)
            return
        }
        
        self.visibleDateComponents = dateComponents
        delegate?.calendarWeekMonthExpandView(self, didChangeVisibleDate: dateComponents)
    }
    
    // MARK: - TPMidnightUpdatable
    func updateAtMidnight() {
        let currentView = containerView.currentView
        if let monthView = currentView as? CalendarExpandMonthView {
            monthView.reloadData()
        } else if let weekView = currentView as? CalendarExpandWeekView {
            weekView.reloadData()
        }
    }

}

// MARK: - 容器代理实现
extension CalendarWeekMonthExpandView: CalendarExpandContainerDelegate {

    func container(_ container: CalendarExpandContainerView, viewFor mode: CalendarExpandMode) -> UIView {
        switch mode {
        case .week:
            let view = CalendarExpandWeekView(frame: .zero)
            view.eventsProvider = eventsInfoFetcher
            view.didChangeVisibleDateComponents = { [weak self] currentComponents, _ in
                self?.changeVisibleDateComponents(currentComponents)
            }
            
            view.firstWeekday = firstWeekday
            view.showLunar = showLunar
            view.showChineseHolidays = showChineseHolidays
            view.selection = selection
            view.setVisibleDateComponents(visibleDateComponents)
            return view
        case .month:
            let view = CalendarExpandMonthView(frame: .zero)
            view.eventsProvider = eventsInfoFetcher
            view.didChangeVisibleDateComponents = { [weak self] currentComponents, _ in
                self?.changeVisibleDateComponents(currentComponents)
            }
            
            view.firstWeekday = firstWeekday
            view.showLunar = showLunar
            view.showChineseHolidays = showChineseHolidays
            view.selection = selection
            view.setVisibleDateComponents(visibleDateComponents)
            return view
        }
    }

    func container(_ container: CalendarExpandContainerView, heightFor mode: CalendarExpandMode) -> CGFloat {
        switch mode {
        case .week:
            return weekHeight
        case .month:
            return monthViewHeight
        }
    }

    func containerWeekRow(_ container: CalendarExpandContainerView) -> Int {
        guard let date = Date.date(from: visibleDateComponents) else { return 0 }
        let dates = date.calendarGridMonthDates(firstWeekday: firstWeekday)
        guard let index = dates.firstIndex(of: date) else {
            return 0
        }
        
        let row = index / 7
        return row
    }

    func container(_ container: CalendarExpandContainerView, didFinishTransitionTo mode: CalendarExpandMode) {
        /// 更新当前可见日期
        var visibleDateComponents = self.visibleDateComponents
        let currentView = containerView.currentView
        if let monthView = currentView as? CalendarExpandMonthView {
            visibleDateComponents = monthView.visibleDateComponents
        } else if let weekView = currentView as? CalendarExpandWeekView {
            visibleDateComponents = weekView.visibleDateComponents
        }
        
        changeVisibleDateComponents(visibleDateComponents)
    }
    
    func containerFrameDidChange(_ container: CalendarExpandContainerView) {
        self.height = contentHeight
        setNeedsLayout()
        layoutIfNeeded()
        delegate?.calendarWeekMonthExpandViewFrameChanged(self)
    }
}

extension CalendarWeekMonthExpandView: TPCalendarSingleDateSelectionDelegate {
    
    /// 选中日期
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        guard containerView.currentMode == .month,
              !visibleDateComponents.isInSameMonth(as: date),
              let monthView = containerView.currentView as? CalendarExpandMonthView else {
                  visibleDateComponents = date
                  delegate?.calendarWeekMonthExpandView(self, didSelectDate: date)
                  if autoSwitchToWeekOnSelectDate {
                      switchMode(.week, animated: true)
                  }
            return
        }
        
        visibleDateComponents = date
        monthView.setVisibleDateComponents(visibleDateComponents, animated: true)
        delegate?.calendarWeekMonthExpandView(self, didSelectDate: date)
    }
}
