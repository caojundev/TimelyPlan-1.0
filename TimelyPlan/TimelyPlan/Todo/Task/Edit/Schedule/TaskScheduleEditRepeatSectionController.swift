//
//  TaskScheduleEditRepeatSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/10.
//

import Foundation

class TaskScheduleEditRepeatSectionController: TPTableItemSectionController,
                                               ScheduleRepeatEditSectionControllerProtocol{
    
    var didChangeRepeatRule: ((RepeatRule?) -> Void)?
    
    var dateInfo: TaskDateInfo?
    
    var repeatRule: RepeatRule?

    lazy var repeatCellItem: TodoTaskEditTableCellItem = {
        return newRepeatCellItem()
    }()
    
    override init() {
        super.init()
        self.cellItems = [repeatCellItem]
    }

    func selectRepeatRule(_ repeatRule: RepeatRule?) {
        if self.repeatRule != repeatRule {
            self.repeatRule = repeatRule
            reloadRepeat()
            didChangeRepeatRule?(repeatRule)
        }
    }
    
    // MARK: - Public
    func reloadRepeat() {
        adapter?.reloadCell(forItem: repeatCellItem, with: .none)
    }
}

protocol ScheduleRepeatEditSectionControllerProtocol: AnyObject {
    
    /// 日期信息
    var dateInfo: TaskDateInfo? {get set}
    
    /// 重复条目
    var repeatRule: RepeatRule? {get set}
    
    /// 重复单元格条目
    var repeatCellItem: TodoTaskEditTableCellItem {get set}
    
    /// 选中重复条谬
    func selectRepeatRule(_ repeatRule: RepeatRule?)
}

extension ScheduleRepeatEditSectionControllerProtocol {
   
    var eventDate: Date? {
        return dateInfo?.startDate
    }
    
    func newRepeatCellItem() -> TodoTaskEditTableCellItem {
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "schedule_repeat_24"
        cellItem.updater = { [weak self] in
            self?.updateRepeatCellItem()
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editRepeat()
        }
        
        cellItem.didClickRightButton = { [weak self] _ in
            self?.selectRepeatRule(nil)
        }
        
        return cellItem
    }
    
    func updateRepeatCellItem() {
        if let eventDate = eventDate, let repeatRule = repeatRule {
            repeatCellItem.title = repeatRule.title(for: eventDate)
            repeatCellItem.subtitle = repeatRule.subtitle(for: eventDate)
            repeatCellItem.isActive = true
        } else {
            repeatCellItem.title = resGetString("Repeat")
            repeatCellItem.subtitle = nil
            repeatCellItem.isActive = false
        }
        
        repeatCellItem.isDisabled = eventDate == nil
    }
    

    private func editRepeat() {
        let editVC = RepeatEditViewController(repeatRule: repeatRule, eventDate: eventDate)
        editVC.didEndEditing = { repeatRule in
            self.selectRepeatRule(repeatRule)
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.popoverShow()
    }
}
