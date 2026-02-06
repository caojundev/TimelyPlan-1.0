//
//  FocusEndSummarySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/28.
//

import Foundation

class FocusEndSummarySectionController: FocusEndSectionController {
    
    /// 时间线单元格
    lazy var timelineCellItem: FocusEndTimelineCellItem = {
        let cellItem = FocusEndTimelineCellItem()
        cellItem.updater = { [weak self] in
            self?.timelineCellItem.dataItem = self?.dataItem
        }
        
        return cellItem
    }()
  
    override init(dataItem: FocusEndDataItem) {
        super.init(dataItem: dataItem)
        self.cellItems = [timelineCellItem]
    }
    
}
