//
//  ScheduledReminderEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/3/24.
//

import Foundation
import UIKit

class ScheduledReminderEditSectionController: TPTableItemSectionController,
                                          TPMultipleItemSelectionDelegate {
    
    /// 是否提醒
    var shouldRemind: Bool = false
    
    /// 是否提醒改变
    var shouldRemindDidChange: ((Bool) -> Void)?
    
    /// 提醒改变
    var reminderDidChange: ((ScheduledReminder) -> Void)?
    
    var reminder: ScheduledReminder {
        get {
            let alarms = selection.selectedItems.sorted()
            return ScheduledReminder(alarms: alarms)
        }
        
        set {
            selection.reset(with: newValue.alarms)
        }
    }

    /// 最大提醒数目
    private let maximumAlarmsCount = 5
    
    /// 是否可以添加提醒
    private var canAddAlarm: Bool {
        return selection.selectedItems.count < maximumAlarmsCount
    }
    
    override init() {
        super.init()
        self.headerItem.title = resGetString("Reminder")
    }
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var cellItems: [TPBaseTableCellItem] = []
            cellItems.append(remindMeCellItem)
            if shouldRemind {
                cellItems.append(alarmListCellItem)
                cellItems.append(alarmAddCellItem)
            }
            
            return cellItems
        }
        
        set {}
    }
    
    /// 提醒我
    lazy var remindMeCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.title = resGetString("Remind Me")
        cellItem.updater = {
            guard let self = self else {
                return
            }
            
            self.remindMeCellItem.isOn = self.shouldRemind
        }
        
        cellItem.valueChanged = { isOn in
            guard let self = self else { return }
            self.shouldRemind = isOn
            self.shouldRemindDidChange?(isOn)
            self.adapter?.performSectionUpdate(forSectionObject: self)
        }
        
        return cellItem
    }()
    
    /// 闹铃选择器
    lazy var selection: TPMultipleItemSelection<TaskAlarm> = {
        let selection = TPMultipleItemSelection<TaskAlarm>(items: [])
        selection.delegate = self
        return selection
    }()
    
    /// 提醒列表
    lazy var alarmListCellItem: AlarmListTableCellItem = { [weak self] in
        let cellItem = AlarmListTableCellItem()
        cellItem.height = 60.0
        cellItem.selection = selection
        cellItem.editingEnabled = true /// 可编辑
        cellItem.isSubtitleHidden = true /// 隐藏副标题
        cellItem.titleConfig.textColor = Color(0xFFFFFF, 0.9)
        cellItem.cellStyle.backgroundColor = .primary
        cellItem.cellStyle.focusLineColor = Color(light: 0x0126C4, dark: 0x8AA0FF)
        cellItem.cellStyle.cornerRadius = .greatestFiniteMagnitude
        return cellItem
    }()
    
    /// 自定义提醒
    lazy var alarmAddCellItem: TPFullSizeButtonTableCellItem = { [weak self] in
        let cellItem = TPFullSizeButtonTableCellItem()
        cellItem.height = 50.0
        cellItem.buttonTitle = resGetString("Add Alarm")
        cellItem.buttonImageName = "bell_add_20"
        cellItem.buttonFixedImageSize = .size(5)
        cellItem.buttonImageColor = Color(0xFFFFFF, 0.9)
        cellItem.buttonNormalTitleColor = Color(0xFFFFFF, 0.9)
        cellItem.buttonNormalBackgroundColor = .primary
        cellItem.buttonSelectedBackgroundColor = .primary.darkerColor
        cellItem.updater = {
            guard let self = self else {
                return
            }
            
            self.alarmAddCellItem.isDisabled = !self.canAddAlarm
        }
        
        cellItem.didClickButton = { _ in
            self?.addAlarm()
        }
        
        return cellItem
    }()
    
    /// 添加新提醒
    func addAlarm() {
        let pickerVC = TPTimePickerViewController()
        pickerVC.didPickDate = { date in
            let offset = date.offset()
            let alarm = TaskAlarm(daysAbsolute: (0, offset))
            self.didCreateAlarm(alarm)
        }
        
        pickerVC.popoverShow()
    }
    
    private func didCreateAlarm(_ alarm: TaskAlarm) {
        if !selection.isSelectedItem(alarm) {
            selection.selectItem(alarm)
        } else {
            /// 已经存在该提醒
            let cell = adapter?.cellForItem(alarmListCellItem) as? AlarmListTableViewCell
            cell?.listView.scrollToAndCommitFocusAnimation(for: alarm)
        }
        
        updateAlarmAddEnabled()
    }
    
    /// 更新提醒添加可用状态
    private func updateAlarmAddEnabled() {
        alarmAddCellItem.updater?()
        if let cell = adapter?.cellForItem(alarmAddCellItem) as? TPFullSizeButtonTableCell {
            cell.isDisabled = alarmAddCellItem.isDisabled
        }
    }
    
    // MARK: - MultipleItemSelectionDelegate
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, canSelectItem item: T) -> Bool where T : Hashable {
        return canAddAlarm
    }

    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, canDeselectItem item: T) -> Bool where T : Hashable {
        return true
    }

    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, didSelectItem item: T) where T : Hashable {
        updateAlarmAddEnabled()
        reminderDidChange?(reminder)
    }

    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, didDeselectItem item: T) where T : Hashable {
        updateAlarmAddEnabled()
        reminderDidChange?(reminder)
    }
}
