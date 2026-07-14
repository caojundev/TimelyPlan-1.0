//
//  FocusTimerMyDayEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/14.
//

import Foundation
import UIKit

class FocusTimerMyDayEditSectionController: DateFrequencySectionController {
    
    /// 添加到我的一天
    var isAddedToMyDay: Bool = true

    /// 日期
    var date: Date?
    
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
    
    /// 时间单元格条目
    private lazy var timeCellItem: TPImageInfoTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageName = "schedule_time_24"
        cellItem.updater = {
            guard let self = self else { return }
            if let date = self.date {
                self.timeCellItem.title = date.timeString
            } else {
                self.timeCellItem.title = resGetString("All Day")
            }
        }
        
        cellItem.didSelectHandler = {
            self?.editTime()
        }
        
        return cellItem
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            guard isAddedToMyDay else {
                return [myDayCellItem]
            }
            
            return [myDayCellItem,
                    dateRangeCellItem,
                    frequencyCellItem,
                    timeCellItem]
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.frequencyCellItem.imageName = "schedule_repeat_24"
    }
    
    private func addToMyDayValueChanged(_ isAddedToMyDay: Bool) {
        self.isAddedToMyDay = isAddedToMyDay
        adapter?.performSectionUpdate(forSectionObject: self,
                                      rowAnimation: .fade,
                                      completion: nil)
    }

    
    // MARK: - Edit
    /// 编辑时间
    private func editTime() {
        let timePicker = TPTimePickerViewController()
        timePicker.date = date ?? .now
        timePicker.didPickDate = { date in
            self.pickTime(date)
        }
        
        timePicker.didClickClear = {
            self.pickTime(nil)
        }
        
        timePicker.popoverShowAsNavigationRoot()
    }
    
    /// 选中时间
    private func pickTime(_ date: Date?) {
        self.date = date
        adapter?.reloadCell(forItem: timeCellItem, with: .none)
    }
    
}
