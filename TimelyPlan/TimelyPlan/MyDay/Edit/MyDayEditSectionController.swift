//
//  MyDayEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/13.
//

import Foundation
import UIKit

class MyDayEditSectionController: TPTableItemSectionController {
    
    /// 添加到我的一天改变回调
    var onAddToMyDayValueChanged: ((Bool) -> Void)?
    
    /// 添加到我的一天
    var isAddedToMyDay: Bool = true

    let defaultCellHeight = 55.0
    
    /// 添加到我的一天
    lazy var myDayCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.imageName = "todo_task_addToMyDay_24"
        cellItem.title = resGetString("Add to My Day")
        cellItem.titleConfig.font = BOLD_SYSTEM_FONT
        cellItem.height = defaultCellHeight
        cellItem.updater = {
            guard let self = self else { return }
            self.myDayCellItem.isOn = self.isAddedToMyDay
        }

        cellItem.valueChanged = { isOn in
            self?.addToMyDayValueChanged(isOn)
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [myDayCellItem]
    }
    
    private func addToMyDayValueChanged(_ isAddedToMyDay: Bool) {
        self.isAddedToMyDay = isAddedToMyDay
        onAddToMyDayValueChanged?(isAddedToMyDay)
    }
    
}
