//
//  StatsCalendarMonthSectionItem.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/8.
//

import Foundation

class HabitStatsCalendarMonthSectionController: TPCollectionItemSectionController,
                                                TPCalendarMonthViewDelegate {
    
    let periodItem: HabitPeriodItem
    
    let date: Date
    
    let firstWeekday: Weekday
    
    /// 月单元格条目
    private let monthCellItem = HabitStatsCalendarMonthCellItem()
    
    init(periodItem: HabitPeriodItem, date: Date, firstWeekday: Weekday = .firstWeekday) {
        self.periodItem = periodItem
        self.date = date
        self.firstWeekday = firstWeekday
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.monthCellItem.date = date
        self.monthCellItem.firstWeekday = firstWeekday
        self.monthCellItem.monthViewDelegate = self
        self.cellItems = [self.monthCellItem]
    }

    // MARK: - TPCalendarMonthViewDelegate
    func calendarMonthView(_ view: TPCalendarMonthView, cellClassForDateComponents components: DateComponents) -> AnyClass? {
        guard let date = Date.dateFromComponents(components), date.isInSameMonthAs(self.date) else {
            return nil
        }
        
        return HabitStatsCalendarMonthDayCell.self
    }
    
    func calendarMonthView(_ view: TPCalendarMonthView, didDequeCell cell: UICollectionViewCell, forDateComponents components: DateComponents) {
        guard let cell = cell as? HabitStatsCalendarMonthDayCell,
              let date = Date.dateFromComponents(components) else {
            return
        }
        
        cell.date = date
        cell.periodItem = self.periodItem
        cell.isScheduledDay = self.periodItem.isScheduledDate(date)
        cell.reloadData() /// 加载内容数据
    }
    
    func calendarMonthView(_ view: TPCalendarMonthView, shouldHighlightDate components: DateComponents) -> Bool? {
        guard let date = Date.dateFromComponents(components) else {
            return false
        }
        
        return !date.isFutureDay
    }
    
    func calendarMonthView(_ view: TPCalendarMonthView, didSelectDate components: DateComponents) {
        guard let date = Date.dateFromComponents(components) else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        let isScheduled = self.periodItem.isScheduledDate(date)
        if isScheduled {
            HabitDayMenuPresenter.showMenu(for: periodItem, on: date)
        } else {
            HabitPresenter.showNotScheduledDayMessage(for: date)
        }
    }
}

class HabitStatsCalendarMonthDayCell: HabitTaskStatusDayCell {
    
    override func updateStyle() {
        guard let periodItem = periodItem, let date = date else {
            return
        }

        let status = periodItem.status(on: date)
        let color = Color(0x5856D6)
        
        /// 背景色
        if !isScheduledDay {
            backgroundView?.backgroundColor = .clear
            selectedBackgroundView?.backgroundColor = .clear
        } else if status == .completed {
            backgroundView?.backgroundColor = color
            selectedBackgroundView?.backgroundColor = color
        } else {
            backgroundView?.backgroundColor = UIColor(white: 0.6, alpha: 0.1)
            selectedBackgroundView?.backgroundColor = UIColor(white: 0.6, alpha: 0.2)
        }
        
        self.statusProgressView.statusImageColor = .white
        self.statusProgressView.progressColor = color
        self.statusProgressView.progressView.backLineColor = Color(light: 0x121212, dark: 0xf1f1f1, alpha: 0.1)
        
        let textColor = resGetColor(.title)
        self.statusProgressView.infoLabel.textColor = textColor
        self.valueLabel.textColor = textColor
        self.emptyLineColor = Color(light: 0x121212, dark: 0xf1f1f1, alpha: 0.2)
    }
    
    
}
