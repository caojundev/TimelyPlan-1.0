//
//  HabitSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation
import UIKit

class HabitSettingViewController: BaseSettingViewController {
     
    /// 周开始日
    lazy var firstWeekdayCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Week Start on")
        cellItem.updater = {
            guard let self = self else { return }
            let firstWeekday = HabitSetting.shared.firstWeekday
            self.firstWeekdayCellItem.valueConfig = .valueText(firstWeekday.symbol)
        }
        
        cellItem.didSelectHandler = {
            self?.editFirstWeekday()
        }
        
        return cellItem
    }()
    
     /// 添加计时器到顶部
     lazy var addHabitOnTopCellItem: TPSwitchTableCellItem = { [weak self] in
         let cellItem = TPSwitchTableCellItem()
         cellItem.height = defaultCellHeight
         cellItem.title = resGetString("Add New Habits On Top")
         cellItem.updater = {
             guard let self = self else { return }
             let isOn = HabitSetting.shared.addHabitOnTop
             self.addHabitOnTopCellItem.isOn = isOn
         }

         cellItem.valueChanged = { isOn in
             HabitSetting.shared.addHabitOnTop = isOn
         }
         
         return cellItem
     }()
    
    /// 原因标签
    lazy var reasonTagCellItem: TPImageInfoTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Reason Tag")
        cellItem.didSelectHandler = {
            self?.editReasonTag()
        }
        
        return cellItem
    }()
     
    lazy var defaultScoreCellItem: TPImageInfoTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Default Score")
        cellItem.didSelectHandler = {
            self?.editDefaultScore()
        }
        
        return cellItem
    }()
     
     lazy var generalSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.height = 10.0
         sectionController.cellItems = [firstWeekdayCellItem,
                                        addHabitOnTopCellItem,
                                        reasonTagCellItem,
                                        defaultScoreCellItem]
         return sectionController
     }()
     
     override func viewDidLoad() {
         super.viewDidLoad()
         self.title = resGetString("Habit Settings")
         self.sectionControllers = [generalSectionController]
         self.reloadData()
     }
    
    private func editFirstWeekday() {
        guard let cell = adapter.cellForItem(firstWeekdayCellItem) else {
            return
        }
        
        let firstWeekday = HabitSetting.shared.firstWeekday
        WeekdayPickerController.show(currentWeekday: firstWeekday,
                                     allowWeekdays: [.sunday, .monday],
                                     from: cell.contentView,
                                     popoverPosition: .bottomLeft,
                                     permittedPositions: [.bottomLeft, .topLeft],
                                     isSourceViewCovered: false,
                                     animated: true) { weekday in
            if firstWeekday != weekday {
                HabitSetting.shared.firstWeekday = weekday
                self.adapter.reloadCell(forItem: self.firstWeekdayCellItem, with: .none)
            }
        }
    }
    
    private func editReasonTag() {
        let vc = HabitReasonTagEditViewController(style: .insetGrouped)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editDefaultScore() {
        let vc = HabitSettingScoreEditViewController(style: .insetGrouped)
        self.navigationController?.pushViewController(vc, animated: true)
    }
 }
