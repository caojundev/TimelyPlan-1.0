//
//  HabitStatsYearlyHistorySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/16.
//

import Foundation
import UIKit

class HabitStatsYearlyHistorySectionController: TPCollectionItemSectionController {

    let task: HabitTask
    
    let date: Date
 
    var monthGroupedRecords: HabitMonthGroupedRecords? {
        didSet {
            updateCellItems()
        }
    }
    
    /// 空白单元格条目
    lazy var emptyCellItem: TPDefaultInfoCollectionCellItem = {
        let cellItem = TPDefaultInfoCollectionCellItem()
        cellItem.title = resGetString("No History")
        cellItem.canHighlight = false
        cellItem.contentPadding = UIEdgeInsets(value: 16.0)
        cellItem.size = CGSize(width: .greatestFiniteMagnitude, height: 100.0)
        cellItem.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        cellItem.titleConfig.textAlignment = .center
        cellItem.titleConfig.alpha = 0.5
        
        /// 自定义样式
        let style = TPCollectionCellStyle()
        style.cornerRadius = 16.0
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .secondarySystemFill
        cellItem.style = style
        return cellItem
    }()

    init(task: HabitTask, date: Date, monthGroupedRecords: HabitMonthGroupedRecords? = nil) {
        self.task = task
        self.date = date
        self.monthGroupedRecords = monthGroupedRecords
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.headerItem.title = resGetString("History")
        self.headerItem.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        self.headerItem.titleConfig.textColor = resGetColor(.title)
        self.headerItem.size = CGSize(width: .greatestFiniteMagnitude, height: 50.0)
        self.headerItem.padding = UIEdgeInsets(top: 20.0,
                                               left: 24.0,
                                               bottom: 0,
                                               right: 16.0)
        self.updateCellItems()
    }

    func updateCellItems() {
        guard let monthGroupedRecords = monthGroupedRecords, monthGroupedRecords.count > 0 else {
            self.cellItems = [emptyCellItem]
            return
        }
        
        var cellItems = [HabitStatsHistoryMonthCellItem]()
        for month in stride(from: MONTHS_PER_YEAR, to: 0, by: -1) {
            guard let records = monthGroupedRecords[month], records.count > 0 else {
                continue
            }
            
            let recordAmount = records.recordAmount
            let finishedDays = records.finishedDays(for: task)
            let avgScore = records.averageScore
            let monthDate = date.dateByReplacingMonthAndDay(month: month, day: 1)!
            let cellItem = HabitStatsHistoryMonthCellItem(date: monthDate,
                                                          recordAmount: recordAmount,
                                                          finishedDays: finishedDays,
                                                          avgScore: avgScore)
            cellItem.delegate = self
            cellItems.append(cellItem)
            
        }
        
        self.cellItems = cellItems
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        guard let cellItem = item(at: index) as? HabitStatsHistoryMonthCellItem else {
            return
        }
        
    }
}
