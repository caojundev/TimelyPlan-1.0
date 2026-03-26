//
//  FocusStopwatchConfigSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/25.
//

import Foundation

class FocusStopwatchConfigSectionController: TPTableItemSectionController {
    
    var config = FocusStopwatchConfig()
    
    lazy var configCellItem: FocusStopwatchConfigCellItem = {
        let cellItem = FocusStopwatchConfigCellItem()
        return cellItem
    }()

    override init() {
        super.init()
        self.headerItem.height = 10.0
        self.cellItems = [configCellItem]
    }
    
}
