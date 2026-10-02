//
//  CalendarPanelPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/29.
//

import Foundation
import UIKit

protocol CalendarPanelPageViewDelegate: AnyObject {
    
    /// 点击事项
    func calendarPanelPageView(_ pageView: CalendarPanelPageView, didTapEvent event: CalendarEvent)
    
    /// 点击更多
    func calendarPanelPageView(_ pageView: CalendarPanelPageView, didTapMoreOnDate date: Date)
    
    /// 点击日期
    func calendarPanelPageView(_ pageView: CalendarPanelPageView, didTapDate date: Date)
    
    /// 选中日期（月历挂件等跳转用）
    func calendarPanelPageView(_ pageView: CalendarPanelPageView, didSelectDate date: Date)
    
    /// 长按日期
    func calendarPanelPageView(_ pageView: CalendarPanelPageView, didLongPressDate date: Date)
}

class CalendarPanelPageView: TPDayPageView {
    
    /// 手势代理对象
    weak var panelDelegate: CalendarPanelPageViewDelegate?
    
    /// 面板布局样式：决定页面 cell 与页面内天元素视图的布局
    var panelStyle: CalendarPanelStyle = .threePlusFourVertical {
        didSet {
            guard panelStyle != oldValue else {
                return
            }
            
            /// 样式变化后使用对应样式的 cell 重新加载
            reloadData()
        }
    }
    
    /// 周开始日
    var firstWeekday: Weekday {
        didSet {
            guard firstWeekday != oldValue else {
                return
            }
            
            /// 按新的周开始日重新校验可见日期
            setVisibleDate(visibleDate, animated: false)
        }
    }
    
    /// 显示农历
    var showLunar: Bool = true
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true

    struct Config {
        /// 左右条目数
        static let nearItemsCount = 6
    }
    
    init(visibleDate: Date = .now,
         firstWeekday: Weekday = .sunday,
         panelStyle: CalendarPanelStyle = .threePlusFourVertical) {
        self.firstWeekday = firstWeekday
        self.panelStyle = panelStyle
        let visibleDate = visibleDate.startOfWeek(firstWeekday: firstWeekday)
        super.init(frame: .zero, visibleDate: visibleDate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func validatedDate(_ date: Date) -> Date {
        return date.startOfWeek(firstWeekday: firstWeekday).startOfDay()
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return panelStyle.pageCellClass
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarPanelPageCell else {
            return
        }
        
        let date = adapter.item(at: indexPath) as! Date
        let panelView = cell.panelView
        panelView.showLunar = showLunar
        panelView.showChineseHolidays = showChineseHolidays
        panelView.firstWeekday = firstWeekday
        panelView.delegate = self
        cell.date = date
        cell.reloadData()
    }
    
    /// 刷新可见页面的天元素视图（农历、节假日设置变化时）
    func reloadWeekDays() {
        let visibleCells = adapter.visibleCells as! [CalendarPanelPageCell]
        for cell in visibleCells {
            let panelView = cell.panelView
            panelView.showLunar = showLunar
            panelView.showChineseHolidays = showChineseHolidays
        }
    }
    
    override func getDates() -> [Date]? {
        let currentDate = visibleDate.startOfWeek(firstWeekday: firstWeekday)
        var dates: [Date] = [currentDate]
        for i in 1...Config.nearItemsCount {
            let leftDate = currentDate.dateByAddingWeeks(-i)!
            dates.insert(leftDate, at: 0)
            let rightDate = currentDate.dateByAddingWeeks(i)!
            dates.append(rightDate)
        }
        
        return dates
    }
}

// MARK: - CalendarPanelSingleViewDelegate
extension CalendarPanelPageView: CalendarPanelSingleViewDelegate {
    
    func calendarPanelSingleView(_ singleView: CalendarPanelSingleView, didTapEvent event: CalendarEvent) {
        panelDelegate?.calendarPanelPageView(self, didTapEvent: event)
    }
    
    func calendarPanelSingleView(_ singleView: CalendarPanelSingleView, didTapMoreOnDate date: Date) {
        panelDelegate?.calendarPanelPageView(self, didTapMoreOnDate: date)
    }
    
    func calendarPanelSingleView(_ singleView: CalendarPanelSingleView, didTapDate date: Date) {
        panelDelegate?.calendarPanelPageView(self, didTapDate: date)
    }
    
    func calendarPanelSingleView(_ singleView: CalendarPanelSingleView, didSelectDate date: Date) {
        panelDelegate?.calendarPanelPageView(self, didSelectDate: date)
    }
    
    func calendarPanelSingleView(_ singleView: CalendarPanelSingleView, didLongPressDate date: Date) {
        panelDelegate?.calendarPanelPageView(self, didLongPressDate: date)
    }
}

class CalendarPanelPageCell: UICollectionViewCell {
    
    /// 面板布局样式（子类重写，用于创建对应样式的页面视图）
    var panelStyle: CalendarPanelStyle {
        return .threePlusFourVertical
    }

    var date: Date? {
        get {
            return panelView.firstDay
        }
        
        set {
            panelView.firstDay = newValue
        }
    }
    
    private(set) lazy var panelView = makePanelView()
    
    /// 创建页面视图（子类按样式重写，返回对应样式的页面视图）
    func makePanelView() -> CalendarPanelSingleView {
        return CalendarPanelSingleView(style: panelStyle)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(panelView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        panelView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func reloadData() {
        panelView.reloadData()
    }
    
}

/// 「3 + 4 (垂直)」样式的页面 cell
class CalendarPanelThreePlusFourVerticalCell: CalendarPanelPageCell {
    
    override var panelStyle: CalendarPanelStyle {
        return .threePlusFourVertical
    }
}

/// 「4 + 4 (水平)」样式的页面 cell
class CalendarPanelFourPlusFourHorizontalCell: CalendarPanelPageCell {
    
    override var panelStyle: CalendarPanelStyle {
        return .fourPlusFourHorizontal
    }
    
    override func makePanelView() -> CalendarPanelSingleView {
        return CalendarPanelFourPlusFourSingleView(style: panelStyle)
    }
}

// MARK: - 样式对应的页面 cell
extension CalendarPanelStyle {
    
    /// 样式对应的页面 cell
    var pageCellClass: AnyClass {
        switch self {
        case .threePlusFourVertical:
            return CalendarPanelThreePlusFourVerticalCell.self
        case .fourPlusFourHorizontal:
            return CalendarPanelFourPlusFourHorizontalCell.self
        }
    }
}
