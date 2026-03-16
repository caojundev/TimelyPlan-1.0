//
//  HabitStatsLogSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/15.
//

import Foundation
import UIKit

class HabitStatsLogSectionController: TPCollectionItemSectionController {
    
    let periodTask: HabitPeriodTask
    
    private(set) var logs: [HabitStatsLog]?
    
    private let recordController = HabitRecordController()
    
    lazy var emptyCellItem: TPCollectionCellItem = {
        let cellItem = TPDefaultInfoCollectionCellItem()
        cellItem.size = CGSize(width: .greatestFiniteMagnitude, height: 80.0)
        cellItem.titleConfig.textAlignment = .center
        cellItem.title = resGetString("No Log")
        cellItem.titleConfig.textColor = .placeholderText
        return cellItem
    }()
    
    init(periodTask: HabitPeriodTask) {
        self.periodTask = periodTask
        super.init()
        self.logs = periodTask.statsLogs()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.headerItem.title = resGetString("Logs")
        self.headerItem.titleConfig.font = BOLD_BODY_FONT
        self.headerItem.size = CGSize(width: .greatestFiniteMagnitude, height: 50.0)
        self.headerItem.padding = UIEdgeInsets(top: 20.0, left: 16.0, bottom: 0, right: 16.0)
        self.updateCellItems()
    }

    private func updateCellItems() {
        guard let logs = logs, logs.count > 0 else {
            /// 空白单元格
            self.cellItems = [emptyCellItem]
            return
        }
        
        var cellItems = [HabitStatsLogCellItem]()
        for log in logs {
            let cellItem = HabitStatsLogCellItem(log: log)
            cellItems.append(cellItem)
        }
        
        self.cellItems = cellItems
    }
    
    override func didSelectItem(at index: Int) {
        guard let cellItem = item(at: index) as? HabitStatsLogCellItem else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        let date = cellItem.log.date
        let record = periodTask.record(on: date)
        recordController.editLog(for: periodTask.habitTask, with: record, on: date)
    }
}
