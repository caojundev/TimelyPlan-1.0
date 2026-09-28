//
//  FocusStatsCalendarMonthSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation
import UIKit

/// 专注统计月日历区块（上方显示日期天，下方显示当日专注时长）
class FocusStatsCalendarMonthSectionController: TPCollectionItemSectionController,
                                                TPCalendarMonthViewDelegate {
    
    /// 统计数据条目
    let dataItem: FocusStatsDataItem
    
    /// 当前统计的月份日期
    let date: Date
    
    /// 周开始日
    let firstWeekday: Weekday
    
    /// 按日归类的专注时长字典
    private let dayDurations: [DayStringKey: Duration]?
    
    /// 月日历条目
    private let monthCellItem = FocusStatsCalendarMonthCellItem()
    
    init(dataItem: FocusStatsDataItem, date: Date, firstWeekday: Weekday = .firstWeekday) {
        self.dataItem = dataItem
        self.date = date
        self.firstWeekday = firstWeekday
        self.dayDurations = dataItem.dayDurations
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.monthCellItem.date = date
        self.monthCellItem.firstWeekday = firstWeekday
        self.monthCellItem.monthViewDelegate = self
        self.cellItems = [self.monthCellItem]
    }
    
    /// 获取指定日期的专注时长
    func duration(on date: Date) -> Duration {
        return self.dayDurations?[date.dayStringKey] ?? 0
    }
    
    // MARK: - TPCalendarMonthViewDelegate
    func calendarMonthView(_ view: TPCalendarMonthView, cellClassForDateComponents components: DateComponents) -> AnyClass? {
        guard let date = Date.dateFromComponents(components), date.isInSameMonthAs(self.date) else {
            return nil
        }
        
        return FocusStatsCalendarMonthDayCell.self
    }
    
    func calendarMonthView(_ view: TPCalendarMonthView, didDequeCell cell: UICollectionViewCell, forDateComponents components: DateComponents) {
        guard let cell = cell as? FocusStatsCalendarMonthDayCell,
              let date = Date.dateFromComponents(components) else {
            return
        }
        
        cell.date = date
        cell.duration = self.duration(on: date)
        cell.reloadData() /// 加载内容数据
    }
    
    func calendarMonthView(_ view: TPCalendarMonthView, shouldHighlightDate components: DateComponents) -> Bool? {
        return false
    }
}
