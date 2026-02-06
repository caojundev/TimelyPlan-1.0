//
//  FocusTimerTypeSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/25.
//

import Foundation
import UIKit

class FocusTimerTypeSectionController: TPTableItemSectionController {
  
    var didChangeTimerType: ((FocusTimerType) -> Void)?
    
    /// 计时器模式
    var timerType: FocusTimerType = .pomodoro {
        didSet {
            timerTypeCellItem.selectedMenuTag = timerType.tag
        }
    }
  
    /// 计时器模式
    lazy var timerTypeCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.imagePosition = .top
        cellItem.height = 100.0
        cellItem.minimumButtonWidth = 100.0
        cellItem.cornerRadius = 16.0
        cellItem.segmentedImageConfig.size = .size(8)
        cellItem.segmentedImageConfig.margins = .init(top: 10.0, bottom: 10.0)
        cellItem.backgroundColor = .clear
        cellItem.menuItems = FocusTimerType.allTypes.segmentedMenuItems()
        cellItem.updater = {
            guard let self = self else { return }
            self.timerTypeCellItem.selectedMenuTag = self.timerType.tag
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            guard let type: FocusTimerType = menuItem.actionType() else {
                return
            }

            self?.selectTimerType(type)
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.title = resGetString("Timer")
        self.cellItems = [timerTypeCellItem]
    }
    
    // MARK: - 操作处理
    /// 选中计时器模式
    func selectTimerType(_ type: FocusTimerType) {
        self.timerType = type
        self.didChangeTimerType?(type)
        self.adapter?.performUpdate(with: .fade, completion: nil)
    }
}
