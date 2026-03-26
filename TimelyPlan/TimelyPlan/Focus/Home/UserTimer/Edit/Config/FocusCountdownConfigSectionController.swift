//
//  FocusCountdownConfigSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/25.
//

import Foundation

class FocusCountdownConfigSectionController: TPTableItemSectionController {
    
    /// 配置改变回调
    var didChangeConfig: ((FocusCountdownConfig) -> (Void))?
    
    var config = FocusCountdownConfig()

    lazy var configCellItem: FocusCountdownConfigCellItem = { [weak self] in
        let cellItem = FocusCountdownConfigCellItem()
        cellItem.updater = {
            self?.configCellItem.config = self?.config
        }
        
        cellItem.configDidChange = { config in
            self?.config = config
            self?.didChangeConfig?(config)
        }
        
        return cellItem
    }()

    override init() {
        super.init()
        self.headerItem.height = 10.0
        self.cellItems = [configCellItem]
    }
    
}
