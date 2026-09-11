//
//  CalendarGoalSettingSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/10.
//

import Foundation
import UIKit

class CalendarGoalSettingSectionController: TPTableItemSectionController {
    
    let defaultCellHeight = 50.0
    
    /// 在日历显示
    lazy var showInCalendarCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show in Calendar")
        cellItem.updater = {
            guard let self = self else { return }
            let isOn = CalendarSetting.shared.showGoal
            self.showInCalendarCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            CalendarSetting.shared.showGoal = isOn
        }

        return cellItem
    }()

    /// 显示范围
    lazy var displayRangeCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Display Range")
        cellItem.updater = {
            guard let self = self else { return }
            let range = CalendarSetting.shared.goalDisplayRange
            self.displayRangeCellItem.valueConfig = .valueText(range.title)
        }

        cellItem.didSelectHandler = {
            self?.editDisplayRange()
        }

        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [showInCalendarCellItem,
                          displayRangeCellItem]
    }
    
    private func editDisplayRange() {
        guard let cell = adapter?.cellForItem(displayRangeCellItem) else {
            return
        }
        
        let displayRange = CalendarSetting.shared.goalDisplayRange
        let menuItem = TPMenuItem.item(with: CalendarEventDisplayRange.allCases,
                                       updater: { range, menuAction in
            menuAction.handleBeforeDismiss = true
            menuAction.isChecked = displayRange == range
        })
        
        let menuVC = TPMenuListViewController()
        menuVC.menuItems = [menuItem]
        menuVC.didSelectMenuAction = { menuAction in
            guard let range: CalendarEventDisplayRange = menuAction.actionType() else {
                return
            }
            
            if CalendarSetting.shared.goalDisplayRange != range {
                CalendarSetting.shared.goalDisplayRange = range
                self.adapter?.reloadCell(forItem: self.displayRangeCellItem, with: .none)
            }
        }
    
        menuVC.popoverShow(from: cell,
                           sourceRect: cell.bounds,
                           isSourceViewCovered: false,
                           preferredPosition: .bottomLeft,
                           permittedPositions: [.bottomLeft, .topLeft],
                           animated: true,
                           completion: nil)
    }
}
