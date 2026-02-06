//
//  TodoTaskQuickAddMenuSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/23.
//

import Foundation
import UIKit

enum TodoTaskQuickAddMenuActionType: Int {
    case addToMyDay
    case schedule
    case priority
    case progress
    case tag
    case note
}

class TodoTaskQuickAddMenuSectionController: TPCollectionItemSectionController,
                                             TodoTaskQuickAddMenuCellDelegate {
    
    /// 当前任务
    var task = TodoQuickAddTask()

    /// 任务改变回调
    var didChangeTask: ((_ task: TodoQuickAddTask, _ actionType: TodoTaskQuickAddMenuActionType) -> Void)?
    
    /// 我的一天
    lazy var addToMyDayCellItem: TodoTaskQuickAddMenuCellItem = { [weak self] in
        let cellItem = TodoTaskQuickAddMenuCellItem(actionType: .addToMyDay)
        cellItem.updater = {
            self?.updateAddToMyDayCellItem()
        }
    
        return cellItem
    }()
    
    /// 日期
    lazy var scheduleCellItem: TodoTaskQuickAddMenuCellItem = { [weak self] in
        let cellItem = TodoTaskQuickAddMenuCellItem(actionType: .schedule)
        cellItem.updater = {
            self?.updateScheduleCellItem()
        }
    
        return cellItem
    }()
    
    /// 优先级
    lazy var priorityCellItem: TodoTaskQuickAddMenuCellItem = { [weak self] in
        let cellItem = TodoTaskQuickAddMenuCellItem(actionType: .priority)
        cellItem.updater = {
            self?.updatePriorityCellItem()
        }
        
        return cellItem
    }()
    
    /// 目标
    lazy var progressCellItem: TodoTaskQuickAddMenuCellItem = { [weak self] in
        let cellItem = TodoTaskQuickAddMenuCellItem(actionType: .progress)
        cellItem.updater = {
            self?.updateProgressCellItem()
        }
        
        return cellItem
    }()
    
    /// 标签
    lazy var tagCellItem: TodoTaskQuickAddMenuCellItem = { [weak self] in
        let cellItem = TodoTaskQuickAddMenuCellItem(actionType: .tag)
        cellItem.updater = {
            self?.updateTagCellItem()
        }
        
        return cellItem
    }()
    
    /// 备注
    lazy var noteCellItem: TodoTaskQuickAddMenuCellItem = { [weak self] in
        let cellItem = TodoTaskQuickAddMenuCellItem(actionType: .note)
        cellItem.updater = {
            self?.updateNoteCellItem()
        }
        
        return cellItem
    }()
    
    /// 活动状态图片外间距
    let activeImageMargins = UIEdgeInsets(right: 5.0)
    
    override init() {
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 10.0, vertical: 0.0)
        self.layout.lineSpacing = 8.0
        self.layout.interitemSpacing = 8.0
        self.cellItems = [scheduleCellItem,
                          addToMyDayCellItem,
                          priorityCellItem,
                          progressCellItem,
                          tagCellItem,
                          noteCellItem]
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        guard let cellItem = item(at: index) as? TodoTaskQuickAddMenuCellItem else {
            return
        }
        
        let actionType = cellItem.actionType
        switch actionType {
        case .addToMyDay:
            selectAddToMyDay()
        case .schedule:
            editSchedule()
        case .priority:
            editPriority()
        case .progress:
            editProgress()
        case .tag:
            editTags()
        case .note:
            selectNote()
        }
    }

    // MARK: - Update
    private func updateImageConfig(for cellItem: TodoTaskQuickAddMenuCellItem, isActive: Bool) {
        cellItem.imageConfig.margins = isActive ? activeImageMargins : .zero
        cellItem.imageConfig.color = isActive ? .white : Color(light: 0x646566, dark: 0xabacad)
        cellItem.imageConfig.shouldRenderImageWithColor = true
    }
    
    private func updateAddToMyDayCellItem() {
        let isActive = task.isAddedToMyDay
        addToMyDayCellItem.isActive = isActive
        addToMyDayCellItem.imageName = "todo_task_addToMyDay_24"
        addToMyDayCellItem.title = isActive ? resGetString("Added to My Day") : nil
        updateImageConfig(for: addToMyDayCellItem, isActive: isActive)
    }
    
    private func updateScheduleCellItem() {
        let isActive = task.isScheduled
        scheduleCellItem.isActive = isActive
        scheduleCellItem.imageName = "todo_task_date_24"
        if isActive {
            let color: UIColor = task.isOverdue ? .danger6 : .primary
            scheduleCellItem.activeCellStyle.backgroundColor = color
            scheduleCellItem.activeCellStyle.selectedBackgroundColor = color
            scheduleCellItem.title = task.schedule?.attributedInfo(isSlashFormattedDate: true,
                                                                    normalColor: .white,
                                                                     highlightedColor: .white,
                                                                     overdueColor: .white,
                                                                     badgeBaselineOffset: 6.0,
                                                                     badgeFont: UIFont.boldSystemFont(ofSize: 8.0),
                                                                     imageSize: .size(4),
                                                                     showRepeatCount: false,
                                                                     separator: "•")
        } else {
            scheduleCellItem.title = nil
        }
        
        updateImageConfig(for: scheduleCellItem, isActive: isActive)
    }
    
    private func updatePriorityCellItem() {
        let priority = task.priority
        let isActive = priority != .none
        priorityCellItem.isActive = isActive
        priorityCellItem.title = isActive ? priority.title : nil
        priorityCellItem.imageName = priority.iconName
        priorityCellItem.activeCellStyle.backgroundColor = priority.color
        priorityCellItem.activeCellStyle.selectedBackgroundColor = priority.color
        updateImageConfig(for: priorityCellItem, isActive: isActive)
    }
    
    private func updateProgressCellItem() {
        var isActive = false
        var title: String? = nil
        if let progress = task.progress {
            isActive = true
            title = progress.detailInfo
        }
        
        progressCellItem.isActive = isActive
        progressCellItem.title = title
        progressCellItem.imageName = "todo_task_progress_24"
        updateImageConfig(for: progressCellItem, isActive: isActive)
    }
    
    private func updateTagCellItem() {
        var isActive = false
        var title: String? = nil
        if let tags = task.tags, tags.count > 0 {
            let format: String
            if tags.count > 1 {
                format = resGetString("%ld tags")
            } else {
                format = resGetString("%ld tag")
            }

            title = String(format: format, tags.count)
            isActive = true
        }
        
        tagCellItem.isActive = isActive
        tagCellItem.title = title
        tagCellItem.imageName = "todo_task_tag_24"
        updateImageConfig(for: tagCellItem, isActive: isActive)
    }
    
    private func updateNoteCellItem() {
        let isActive = task.isNoteEnabled
        noteCellItem.isActive = isActive
        noteCellItem.title = isActive ? resGetString("Note") : nil
        noteCellItem.imageName = "todo_task_note_24"
        updateImageConfig(for: noteCellItem, isActive: isActive)
    }

    func reload(for actionType: TodoTaskQuickAddMenuActionType) {
        var cellItem: TodoTaskQuickAddMenuCellItem?
        switch actionType {
        case .addToMyDay:
            cellItem = addToMyDayCellItem
        case .schedule:
            cellItem = scheduleCellItem
        case .priority:
            cellItem = priorityCellItem
        case .progress:
            cellItem = progressCellItem
        case .tag:
            cellItem = tagCellItem
        case .note:
            cellItem = noteCellItem
        }
        
        if let cellItem = cellItem {
            adapter?.reloadCell(forItem: cellItem)
        }
    }
    
    // MARK: - Menu Action
    private func selectAddToMyDay() {
        if !task.isAddedToMyDay {
            setAddToMyDay(true)
        }
    }

    private func editSchedule() {
        TodoTaskController.editSchedule(task.schedule) {[weak self] newSchedule in
            self?.setSchedule(newSchedule)
        }
    }

    private func editPriority() {
        guard let cell = adapter?.cellForItem(priorityCellItem) else {
            return
        }
        
        let popoverView = TPMenuListPopoverView()
        let menuItem = TPMenuItem.item(with: TodoTaskPriority.priorities) { _, action in
            action.handleBeforeDismiss = true
        }
        
        popoverView.menuItems = [menuItem]
        popoverView.didSelectMenuAction = { action in
            guard let priority = TodoTaskPriority(rawValue: action.tag) else {
                return
            }
            
            self.setPriority(priority)
        }
        
        popoverView.show(from: cell,
                         sourceRect: cell.bounds,
                         isCovered: false,
                         preferredPosition: .topRight,
                         permittedPositions: TPPopoverPosition.topPopoverPositions,
                         animated: true)
    }
    
    /// 编辑目标
    private func editProgress() {
        TodoTaskController.editProgress(task.progress) {[weak self] newProgress in
            self?.setProgress(newProgress)
        }
    }
    
    private func editTags() {
        TodoTaskController.editTags(task.tags) {[weak self] newTags in
            self?.setTags(newTags)
        }
    }
    
    private func selectNote() {
        if !task.isNoteEnabled {
            setNoteEnabled(true)
        }
    }
    
    // MARK: - Setters
    private func setAddToMyDay(_ isAddedToMyDay: Bool) {
        guard task.isAddedToMyDay != isAddedToMyDay else {
            return
        }
        
        task.isAddedToMyDay = isAddedToMyDay
        reload(for: .addToMyDay)
        didChangeTask?(task, .addToMyDay)
    }
    
    private func setPriority(_ priority: TodoTaskPriority) {
        guard task.priority != priority else {
            return
        }
        
        task.priority = priority
        reload(for: .priority)
        didChangeTask?(task, .priority)
    }
    
    private func setSchedule(_ schedule: TaskSchedule?) {
        guard task.schedule != schedule else {
            return
        }
        
        task.schedule = schedule
        reload(for: .schedule)
        didChangeTask?(task, .schedule)
    }
    
    private func setProgress(_ progress: TodoEditProgress?) {
        guard task.progress != progress else {
            return
        }
        
        task.progress = progress
        reload(for: .progress)
        didChangeTask?(task, .progress)
    }
    
    private func setTags(_ tags: Set<TodoTag>?) {
        guard task.tags != tags else {
            return
        }
        
        task.tags = tags
        reload(for: .tag)
        didChangeTask?(task, .tag)
    }
    
    private func setNoteEnabled(_ isEnabled: Bool) {
        guard task.isNoteEnabled != isEnabled else {
            return
        }
        
        task.isNoteEnabled = isEnabled
        reload(for: .note)
        didChangeTask?(task, .note)
    }
    
    // MARK: - TodoTaskQuickAddMenuCellDelegate
    func todoTaskQuickAddMenuCellDidClickDelete(_ cell: TodoTaskQuickAddMenuCell) {
        guard let cellItem = cell.cellItem as? TodoTaskQuickAddMenuCellItem else {
            return
        }
        
        let actionType = cellItem.actionType
        switch actionType {
        case .addToMyDay:
            setAddToMyDay(false)
        case .schedule:
            setSchedule(nil)
        case .priority:
            setPriority(.none)
        case .progress:
            setProgress(nil)
        case .tag:
            setTags(nil)
        case .note:
            setNoteEnabled(false)
        }
    }
}
