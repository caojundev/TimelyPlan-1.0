//
//  TodoTaskEditScheduleSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/8.
//

import Foundation

class ScheduleDateCellItem: TodoTaskEditTableCellItem {
    
    /// 是否已逾期
    var isOverdue: Bool = false {
        didSet {
            updateConfig()
        }
    }
    
    override func updateConfig() {
        super.updateConfig()
        guard isActive else {
            return
        }
        
        if isOverdue {
            /// 逾期样式配置
            imageConfig.color = .redPrimary
            titleConfig.textColor = .redPrimary
            subtitleConfig.textColor = .redPrimary
        }
    }
}

class TodoTaskEditScheduleSectionController: TPTableItemSectionController,
                                                ScheduleReminderEditSectionControllerProtocol,
                                                ScheduleRepeatEditSectionControllerProtocol {

    var dateInfo: TaskDateInfo? {
        get {
            return schedule?.dateInfo
        }
        
        set {
            schedule?.dateInfo = newValue
        }
    }
    
    var reminder: TaskReminder? {
        get {
            return schedule?.reminder
        }
        
        set {
            schedule?.reminder = newValue
        }
    }
    
    var repeatRule: RepeatRule? {
        get {
            return schedule?.repeatRule
        }
        
        set {
            schedule?.repeatRule = newValue
        }
    }
    
    /// 日期
    lazy var dateCellItem: ScheduleDateCellItem = { [weak self] in
        let cellItem = ScheduleDateCellItem()
        cellItem.imageName = "todo_task_date_24"
        cellItem.updater = {
            self?.updateDateCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editSchedule()
        }
        
        cellItem.didClickRightButton = { _ in
            self?.selectSchedule(nil)
        }
        
        return cellItem
    }()

    lazy var reminderCellItem: TodoTaskEditTableCellItem = {
        return newReminderCellItem()
    }()
    
    lazy var repeatCellItem: TodoTaskEditTableCellItem = {
        return newRepeatCellItem()
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            /// 更新当前计划
            self.schedule = task.schedule
            var cellItems: [TPBaseTableCellItem] = [dateCellItem]
            if schedule?.dateInfo != nil {
                cellItems.append(reminderCellItem)
                cellItems.append(repeatCellItem)
            }
            
            return cellItems
        }
        
        set {}
    }
    
    private var schedule: TaskSchedule?
    
    let task: TodoTask
    
    init(task: TodoTask) {
        self.task = task
        super.init()
        self.setupSeparatorFooterItem()
    }
    
    
    // MARK: - 计划
    private func updateDateCellItem() {
        if let dateInfo = self.dateInfo {
            dateCellItem.isOverdue = dateInfo.isOverdue
            dateCellItem.isActive = true
            
            let textColor: UIColor = dateCellItem.isOverdue ? .redPrimary : .primary
            dateCellItem.title = dateInfo.attributedTitle(textColor: textColor,
                                                                    badgeBaselineOffset: 8.0,
                                                                    badgeFont: .boldSystemFont(ofSize: 8.0))
        } else {
            dateCellItem.title = resGetString("Date")
            dateCellItem.isOverdue = false
            dateCellItem.isActive = false
        }
    }

    let taskController = TodoTaskController()
    
    private func editSchedule() {
        TodoTaskController.editSchedule(schedule) {[weak self] newSchedule in
            self?.selectSchedule(newSchedule)
        }
    }

    private func selectSchedule(_ schedule: TaskSchedule?) {
        guard self.schedule != schedule else {
            return
        }
        
        self.schedule = schedule
        updateTaskSchedule()
        adapter?.reloadCell(forItems: [dateCellItem, reminderCellItem, repeatCellItem], with: .none)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .automatic)
    }
    
    // MARK: - 提醒
    func selectReminder(_ reminder: TaskReminder?) {
        if self.reminder != reminder {
            self.reminder = reminder
            updateTaskSchedule()
            adapter?.reloadCell(forItem: reminderCellItem, with: .none)
            adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .automatic)
        }
    }
    
    func selectRepeatRule(_ repeatRule: RepeatRule?) {
        if self.repeatRule != repeatRule {
            self.repeatRule = repeatRule
            updateTaskSchedule()
            adapter?.reloadCell(forItem: repeatCellItem, with: .none)
            adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .automatic)
        }
    }
    
    /// 更新任务计划数据
    private func updateTaskSchedule() {
        todo.updateTask(task, schedule: self.schedule)
    }
    
}
