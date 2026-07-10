//
//  CalendarWeekMonthExpandView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/7.
//

import Foundation
import UIKit

protocol CalendarWeekMonthExpandViewDelegate: AnyObject {
    func calendarWeekMonthExpandViewFrameChanged(_ view: CalendarWeekMonthExpandView)
}

class CalendarWeekMonthExpandView: UIView {
    
    weak var delegate: CalendarWeekMonthExpandViewDelegate?
    
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
        let view = TPWeekdaySymbolView(frame: .zero, style: .short)
        view.backgroundColor = .systemBackground
        view.firstWeekday = firstWeekday
        view.addSeparator(position: .bottom)
        return view
    }()

    /// 周月切换容器（仅负责手势+动画+子视图管理）
    private lazy var containerView: CalendarExpandContainerView = {
        let container = CalendarExpandContainerView(initialMode: .month)
        container.delegate = self
        return container
    }()
    
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
    private(set) var visibleDateComponents: DateComponents = Date().yearMonthDayComponents
    
    private let eventsInfoFetcher = CalendarRangeEventsInfoFetcher()
    
    // MARK: - 初始化
    init(frame: CGRect, firstWeekday: Weekday = .firstWeekday) {
        self.firstWeekday = firstWeekday
        super.init(frame: frame)
        setupViews()
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
    func reloadData() {
        reloadWeekdaySymbol()
    }

    /// 外部手动切换周/月模式
    func switchMode(_ mode: CalendarExpandMode, animated: Bool) {
        containerView.switchToMode(mode, animated: animated)
    }

    // MARK: - 私有方法
    private func reloadWeekdaySymbol() {
        if weekdaySymbolView.firstWeekday != firstWeekday {
            weekdaySymbolView.firstWeekday = firstWeekday
            weekdaySymbolView.reloadData()
        }
    }
    
    private func didChangeVisibleDateComponents(_ dateComponents: DateComponents) {
        if containerView.currentMode == .month,
           let selectedDate = selection.selectedDate,
           selectedDate.isInSameMonth(as: dateComponents) {
            self.visibleDateComponents = selectedDate
            return
        }
        
        self.visibleDateComponents = dateComponents
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
                self?.didChangeVisibleDateComponents(currentComponents)
            }
            
            view.firstWeekday = firstWeekday
            view.selection = selection
            view.setVisibleDateComponents(visibleDateComponents, animated: false)
            return view
        case .month:
            let view = CalendarExpandMonthView(frame: .zero)
            view.eventsProvider = eventsInfoFetcher
            view.didChangeVisibleDateComponents = { [weak self] currentComponents, _ in
                self?.didChangeVisibleDateComponents(currentComponents)
            }
            
            view.firstWeekday = firstWeekday
            view.selection = selection
            view.setVisibleDateComponents(visibleDateComponents, animated: false)
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
            return
        }
        
        visibleDateComponents = date
        monthView.setVisibleDateComponents(visibleDateComponents, animated: true)
    }
}
