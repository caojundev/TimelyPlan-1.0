//
//  StatsCalendarMonthSectionItem.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/8.
//

import Foundation

class HabitStatsCalendarMonthSectionController: TPCollectionItemSectionController,
                                                TPCalendarMonthViewDelegate {
    
    let task: HabitPeriodTask
    
    let date: Date
    
    let firstWeekday: Weekday
    
    /// 月单元格条目
    private let monthCellItem = HabitStatsCalendarMonthCellItem()

    private let dayMenuController = HabitDayMenuController()
    
    init(task: HabitPeriodTask, date: Date, firstWeekday: Weekday = .firstWeekday) {
        self.task = task
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
        cell.task = self.task
        cell.isScheduledDay = self.task.isScheduledDate(date)
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
        dayMenuController.showMenu(for: task, on: date)
    }
}

class HabitStatsCalendarMonthDayCell: HabitTaskStatusDayCell {
    
    override func updateStyle() {
        guard let task = task, let date = date else {
            return
        }

        let status = task.status(on: date)
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
        let textColor = resGetColor(.title)
        self.statusProgressView.infoLabel.textColor = textColor
        self.valueLabel.textColor = textColor
        self.emptyLineColor = Color(light: 0x121212, dark: 0xf1f1f1, alpha: 0.2)
    }
    
    
}
