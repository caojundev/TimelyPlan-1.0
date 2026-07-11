//
//  HabitStatsCalendarWeekSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/15.
//

import Foundation

class HabitStatsCalendarWeekSectionController: TPCollectionItemSectionController {

    let periodItem: HabitPeriodItem
    
    let date: Date
    
    let firstWeekday: Weekday
    
    /// 周单元格条目
    private let weekCellItem = HabitStatsCalendarWeekCellItem()
    
    init(periodItem: HabitPeriodItem, date: Date, firstWeekday: Weekday = .firstWeekday) {
        self.periodItem = periodItem
        self.date = date
        self.firstWeekday = firstWeekday
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.weekCellItem.weekViewDelegate = self
        self.cellItems = [self.weekCellItem]
    }
}

extension HabitStatsCalendarWeekSectionController: HabitDatePeriodsViewDelegate {
    
    // MARK: - PeriodsViewDelegate
    func periodsInDatePeriodsView(_ view: HabitDatePeriodsView) -> [HabitDatePeriod]? {
        return HabitDatePeriod.weekDaysPeriods(containing: self.date,
                                               firstWeekday: self.firstWeekday)
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, cellClassForPeriod period: HabitDatePeriod) -> AnyClass {
        return HabitStatsCalendarWeekDayCell.self
    }

    func datePeriodsView(_ view: HabitDatePeriodsView, didDequeCell cell: UICollectionViewCell, forPeriod period: HabitDatePeriod) {
        let cell = cell as! HabitStatsCalendarWeekDayCell
        let date = period.date
        cell.date = date
        cell.periodItem = self.periodItem
        cell.isScheduledDay = self.periodItem.isScheduledDate(date)
        cell.reloadData() /// 加载内容数据
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, shouldHighlightPeriod period: HabitDatePeriod) -> Bool {
        return !period.isFuture /// 未来时段禁止高亮
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, didSelectPeriod period: HabitDatePeriod) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let isScheduled = periodItem.isScheduledDate(period.date)
        if isScheduled {
            HabitDayMenuPresenter.showPopoverMenu(for: periodItem, on: period.date)
        } else {
            HabitPresenter.showNotScheduledDayMessage(for: period.date)
        }
    }
}

class HabitStatsCalendarWeekDayCell: HabitHomeWeekDayCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.symbolLabel.textColor = .secondaryLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateStyle() {
        guard let periodItem = self.periodItem, let date = date else {
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
        self.statusProgressView.progressView.backLineColor = Color(light: 0x121212, dark: 0xf1f1f1, alpha: 0.1)
        
        self.statusProgressView.progressColor = color
        let textColor = resGetColor(.title)
        self.statusProgressView.infoLabel.textColor = textColor
        self.valueLabel.textColor = textColor
        self.emptyLineColor = Color(light: 0x121212, dark: 0xf1f1f1, alpha: 0.2)
    }
    
    
}

