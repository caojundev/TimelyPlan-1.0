//
//  CountdownDateEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/16.
//

import Foundation
import UIKit

/// 倒数日日期编辑区块
/// 负责展示与编辑目标日期、重复规则与提醒，
/// 数据变更时通过回调通知外部（由外部同步到数据模型）。
class CountdownDateEditSectionController: TPTableItemSectionController {
    
    struct Config {
        static let sectionTitleHeaderHeight = 50.0
        
        static let sectionHeaderPadding = UIEdgeInsets(top: 15.0,
                                                       left: 0.0,
                                                       bottom: 0.0,
                                                       right: 16.0)
        
        static let defaultCellHeight = 55.0
    }
    
    /// 目标日期改变回调
    var onDateChanged: ((CountdownDate) -> Void)?
    
    /// 重复规则改变回调（nil 表示不重复）
    var onTimePlanChanged: ((CountdownTimePlan?) -> Void)?
    
    /// 提醒改变回调（nil 表示无提醒）
    var onReminderChanged: ((TaskReminder?) -> Void)?
    
    /// 目标日期
    var date: CountdownDate = CountdownDate()
    
    /// 时间计划（nil 表示不重复）
    var timePlan: CountdownTimePlan?
    
    /// 提醒
    var reminder: TaskReminder?
    
    // MARK: - 单元格
    /// 目标日期
    lazy var targetDateCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.imageName = "calendar_24"
        cellItem.updater = {
            guard let self = self else { return }
            self.targetDateCellItem.title = self.date.displayText
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editTargetDate()
        }
        
        return cellItem
    }()
    
    /// 重复
    lazy var repeatRuleCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.imageName = "schedule_repeat_24"
        cellItem.title = resGetString("Repeat")
        cellItem.updater = {
            guard let self = self else { return }
            self.updateRepeatRuleCellItem()
        }
    
        cellItem.didSelectHandler = { [weak self] in
            self?.editRepeatRule()
        }
        
        return cellItem
    }()
    
    /// 提醒
    lazy var reminderCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.imageName = "schedule_alarm_24"
        cellItem.title = resGetString("Reminder")
        cellItem.subtitleConfig.font = .boldSystemFont(ofSize: 11.0)
        cellItem.updater = {
            guard let self = self else { return }
            self.updateReminderCellItem()
        }
    
        cellItem.didSelectHandler = { [weak self] in
            self?.editReminder()
        }
        
        return cellItem
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            return [targetDateCellItem, repeatRuleCellItem, reminderCellItem]
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.headerItem.title = resGetString("Target Date")
        self.headerItem.height = Config.sectionTitleHeaderHeight
        self.headerItem.padding = Config.sectionHeaderPadding
        self.footerItem.height = 0.0
    }
    
    // MARK: - 日期
    /// 编辑目标日期
    func editTargetDate() {
        let vc = CountdownDatePickerViewController(countdownDate: date)
        vc.didPickDate = { [weak self] date in
            guard let self = self else { return }
            self.date = date
            self.onDateChanged?(date)
            self.adapter?.reloadCell(forItem: self.targetDateCellItem, with: .none)
        }
        
        vc.popoverShow()
    }
    
    // MARK: - 重复规则
    /// 更新重复规则单元格
    private func updateRepeatRuleCellItem() {
        guard let title = timePlan?.descriptionTitle else {
            repeatRuleCellItem.valueConfig = .valueText(nil)
            return
        }
        
        repeatRuleCellItem.valueConfig = .valueText(title)
    }
    
    /// 编辑重复规则
    private func editRepeatRule() {
        guard let cell = adapter?.cellForItem(repeatRuleCellItem) else {
            return
        }
        
        let menuVC = CountdownRepeatMenuController(date: date,
                                                   timePlan: timePlan)
        menuVC.didSelectMenuActionType = { [weak self] menuType in
            self?.selectTimePlanType(menuType)
        }
        
        menuVC.showMenu(from: cell,
                        sourceRect: cell.bounds,
                        isCovered: false)
    }
    
    private func selectTimePlanType(_ type: CountdownTimePlanType) {
        switch type {
        case .none:
            changeTimePlan(nil)
        case .daily, .weekly, .monthly, .yearly:
            changeTimePlan(CountdownTimePlan(type: type))
        case .custom:
            customRepeatRule()
        }
    }
    
    private func customRepeatRule() {
        let rule = timePlan?.recurrenceRule ?? TaskTimePlanRegularRule()
        let vc = CountdownRepeatCustomViewController(rule: rule)
        vc.didEndEditing = { [weak self] rule in
            let timePlan = CountdownTimePlan(type: .custom, recurrenceRule: rule)
            self?.changeTimePlan(timePlan)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
    
    /// 变更重复规则（nil 表示不重复）
    func changeTimePlan(_ timePlan: CountdownTimePlan?) {
        self.timePlan = timePlan
        onTimePlanChanged?(timePlan)
        adapter?.reloadCell(forItem: repeatRuleCellItem, with: .none)
    }
    
    // MARK: - 提醒
    /// 更新提醒单元格
    private func updateReminderCellItem() {
        guard let reminder = reminder else {
            reminderCellItem.subtitle = nil
            return
        }
        
        reminderCellItem.subtitle = reminder.startAlarmsInfo(with: nil)
    }
    
    /// 编辑提醒
    private func editReminder() {
        let editVC = ReminderEditViewController(reminder: reminder,
                                                isAllDay: true,
                                                startDate: date.targetDate,
                                                endDate: nil)
        editVC.didEndEditing = { [weak self] reminder in
            self?.selectReminder(reminder)
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.popoverShow()
    }
    
    /// 选择提醒（无提醒时置为 nil）
    func selectReminder(_ reminder: TaskReminder?) {
        if let reminder = reminder, reminder.hasAlarm {
            self.reminder = reminder
        } else {
            self.reminder = nil
        }
        
        onReminderChanged?(self.reminder)
        adapter?.reloadCell(forItem: reminderCellItem, with: .none)
    }
}
