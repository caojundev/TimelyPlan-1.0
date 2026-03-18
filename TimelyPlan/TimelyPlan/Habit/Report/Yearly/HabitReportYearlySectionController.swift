//
//  HabitReportYearlySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation

class HabitReportYearlySectionController: HabitReportContentSectionController {
    
    override init(periodTasks: [HabitPeriodTask]?, firstWeekday: Weekday) {
        super.init(periodTasks: periodTasks, firstWeekday: firstWeekday)
        self.cellStyle.cornerRadius = 12.0
        self.layout.preferredItemHeight = 200.0
        self.layout.minimumItemsCountPerRow = 1
        self.layout.maximumItemsCountPerRow = 1
        self.layout.edgeMargins = UIEdgeInsets(value: 16.0)
        self.layout.preferredItemWidth = 480.0
        self.layout.lineSpacing = 10.0
        self.layout.interitemSpacing = 10.0
    }
  
    override func sizeForItem(at index: Int) -> CGSize {
        let size = super.sizeForItem(at: index)
        return size
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return HabitReportYearlyCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        guard let cell = cell as? HabitReportYearlyCell else {
            return
        }
        
        cell.periodTask = item(at: index) as? HabitPeriodTask
        cell.reloadData()
    }
}

