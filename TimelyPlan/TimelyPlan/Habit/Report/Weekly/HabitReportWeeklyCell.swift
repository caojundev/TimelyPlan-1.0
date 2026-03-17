//
//  HabitReportWeeklyCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

class HabitReportWeeklyCell: TPCollectionCell, TPCalendarSingleWeekViewDelegate {
    
    static let weekMargins = UIEdgeInsets(left: 120.0, right: 0.0)
    
    /// 任务
    var periodTask: HabitPeriodTask?
    
    /// 任务信息视图
    private(set) lazy var infoView: HabitReportIconInfoView = {
        let view = HabitReportIconInfoView()
        view.padding = UIEdgeInsets(left: 5.0)
        return view
    }()

    /// 月视图
    private lazy var weekView: TPCalendarSingleWeekView = {
        let view = TPCalendarSingleWeekView(frame: bounds)
        view.delegate = self
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(infoView)
        contentView.addSubview(weekView)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.bounds
        
        let weekLayoutFrame = layoutFrame.inset(by: Self.weekMargins)
        infoView.width = weekLayoutFrame.minX
        infoView.height = layoutFrame.height
        infoView.origin = layoutFrame.origin
        
        weekView.width = weekLayoutFrame.width
        weekView.height = weekLayoutFrame.height
        weekView.top = weekLayoutFrame.minY
        weekView.left = weekLayoutFrame.minX
    }
    
    func reloadData() {
        guard let periodTask = periodTask else {
            return
        }

        let habitTask = periodTask.habitTask
        infoView.icon = habitTask.icon
        infoView.title = habitTask.name
        weekView.firstWeekday = periodTask.period.firstWeekday
        weekView.visibleDateComponents = periodTask.period.date.yearMonthDayComponents
        weekView.reloadData()
    }

    // MARK: - TPCalendarSingleWeekViewDelegate
    func calendarSingleWeekView(_ view: TPCalendarSingleWeekView, cellClassForDateComponents components: DateComponents) -> AnyClass? {
        let date = Date.dateFromComponents(components)
        return HabitReportDayCell.cellClass(for: periodTask, on: date)
    }
    
    func calendarSingleWeekView(_ view: TPCalendarSingleWeekView, didDequeCell cell: UICollectionViewCell, forDateComponents components: DateComponents) {
        guard let cell = cell as? HabitReportDayCell else {
            return
        }
        
        cell.periodTask = periodTask
        cell.date = .dateFromComponents(components)
        cell.reloadData()
    }
    
    func calendarSingleWeekView(_ view: TPCalendarSingleWeekView, shouldHighlightDate components: DateComponents) -> Bool {
       return false
    }
}
