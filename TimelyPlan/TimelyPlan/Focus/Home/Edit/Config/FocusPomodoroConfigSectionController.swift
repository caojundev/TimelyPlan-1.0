//
//  FocusPomodoroConfigSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/25.
//

import Foundation

class FocusPomodoroConfigSectionController: TPTableItemSectionController {
    
    /// 配置改变回调
    var didChangeConfig: ((FocusPomodoroConfig) -> (Void))?
    
    var config = FocusPomodoroConfig()

    lazy var configCellItem: FocusPomodoroConfigCellItem = { [weak self] in
        let cellItem = FocusPomodoroConfigCellItem()
        cellItem.updater = {
            self?.configCellItem.config = self?.config
        }
        
        cellItem.configDidChange = { config in
            self?.config = config
            self?.didChangeConfig?(config)
            self?.updateDescription()
        }
        
        return cellItem
    }()
    
    /// 描述信息单元格
    lazy var descriptionCellItem: TPDescriptionTableCellItem = {
        let cellItem = TPDescriptionTableCellItem()
        cellItem.selectionStyle = .none
        cellItem.updater = { [weak self] in
            guard let self = self else { return }
            self.descriptionCellItem.attributedText = self.config.attributedInfo
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.height = 10.0
        self.cellItems = [descriptionCellItem,
                          configCellItem]
    }
    
    func updateDescription() {
        self.adapter?.reloadCell(forItem: descriptionCellItem, with: .none)
    }
}
