//
//  HabitReportMonthlySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

class HabitReportMonthlySectionController: HabitReportContentSectionController {
    
    let cellContentPadding = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 10.0, right: 5.0)
    
    override init(periodTasks: [HabitPeriodTask]?, firstWeekday: Weekday) {
        super.init(periodTasks: periodTasks, firstWeekday: firstWeekday)
        self.cellStyle.cornerRadius = 12.0
        self.layout.edgeMargins = UIEdgeInsets(value: 16.0)
        self.layout.lineSpacing = 16.0
        self.layout.interitemSpacing = 16.0
        self.layout.minimumItemsCountPerRow = 2
        self.layout.maximumItemsCountPerRow = 4
        self.layout.preferredItemWidth = 240.0
        self.layout.preferredItemHeight = 180.0
    }
  
    override func sizeForItem(at index: Int) -> CGSize {
        let size = super.sizeForItem(at: index)
        let periodTask = item(at: index) as! HabitPeriodTask
        let weeksCount = periodTask.period.date.numberOfWeeksInMonth(firstWeekday: self.firstWeekday)
        
        let chartWidth = size.width - cellContentPadding.horizontalLength
        let itemMargin = 5.0
        let lineSpacing = 5.0
        let itemWidth = (chartWidth - CGFloat(DAYS_PER_WEEK + 1) * itemMargin) / CGFloat(DAYS_PER_WEEK)
        let chartHeight = CGFloat(weeksCount) * (itemWidth + lineSpacing) + lineSpacing
        let cellHeight = chartHeight + HabitReportMonthlyCell.infoViewHeight + cellContentPadding.verticalLength
        return CGSize(width: size.width, height: cellHeight)
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return HabitReportMonthlyCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        guard let cell = cell as? HabitReportMonthlyCell else {
            return
        }
        
        cell.contentView.padding = cellContentPadding
        cell.periodTask = item(at: index) as? HabitPeriodTask
        cell.reloadData()
    }
}

