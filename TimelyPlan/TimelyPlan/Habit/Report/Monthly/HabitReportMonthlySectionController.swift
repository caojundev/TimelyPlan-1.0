//
//  HabitReportMonthlySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

class HabitReportMonthlySectionController: HabitReportContentSectionController {
    
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
        return size
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return HabitReportMonthlyCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        guard let cell = cell as? HabitReportMonthlyCell else {
            return
        }
        
        cell.periodTask = item(at: index) as? HabitPeriodTask
        cell.reloadData()
    }
}

