//
//  TaskScheduleEditReminderSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/10.
//

import Foundation

class TaskScheduleEditReminderSectionController: TPTableItemSectionController,
                                                    ScheduleReminderEditSectionControllerProtocol {
 
    /// 日期信息
    var dateInfo: TaskDateInfo?
    
    var reminder: TaskReminder?
    
    var didChangeReminder: ((TaskReminder?) -> Void)?
    
    lazy var reminderCellItem: TodoTaskEditTableCellItem = {
        return newReminderCellItem()
    }()
    
    override init() {
        super.init()
        self.cellItems = [reminderCellItem]
        self.setupSeparatorFooterItem()
    }

    func selectReminder(_ reminder: TaskReminder?) {
        if self.reminder != reminder {
            self.reminder = reminder
            reloadReminder()
            didChangeReminder?(reminder)
        }
    }

    // MARK: - Public
    func reloadReminder() {
        if let dateInfo = dateInfo {
            reminder?.update(dateInfo: dateInfo)
        } else {
            reminder = nil
        }
        
        adapter?.reloadCell(forItem: reminderCellItem, with: .none)
    }
}

protocol ScheduleReminderEditSectionControllerProtocol: AnyObject {
    
    /// 日期范围
    var dateInfo: TaskDateInfo? {get set}
    
    /// 提醒
    var reminder: TaskReminder? {get set}
    
    /// 提醒单元格条目
    var reminderCellItem: TodoTaskEditTableCellItem {get set}
    
    /// 选中提醒
    func selectReminder(_ reminder: TaskReminder?)
}

extension ScheduleReminderEditSectionControllerProtocol {
   
    func newReminderCellItem() -> TodoTaskEditTableCellItem {
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "schedule_alarm_24"
        cellItem.updater = { [weak self] in
            self?.updateReminderCellItem()
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editReminder()
        }
        
        cellItem.didClickRightButton = { [weak self] _ in
            self?.selectReminder(nil)
        }
        
        return cellItem
    }
    
    
    func updateReminderCellItem() {
        reminderCellItem.title = resGetString("Reminder")
        if let dateInfo = dateInfo, let reminder = reminder, reminder.hasAlarm {
            reminderCellItem.subtitle = reminder.info(with: dateInfo)
            reminderCellItem.isActive = true
        } else {
            reminderCellItem.subtitle = nil
            reminderCellItem.isActive = false
        }
        
        reminderCellItem.isDisabled = dateInfo == nil
    }

    func editReminder() {
        guard let dateInfo = self.dateInfo else {
            return
        }
        
        let editVC = ReminderEditViewController(reminder: reminder, dateInfo: dateInfo)
        editVC.didEndEditing = { reminder in
            self.selectReminder(reminder)
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.popoverShow()
    }
}
