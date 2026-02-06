//
//  TodoTaskEditAddToMyDaySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/9.
//

import Foundation

class TodoTaskEditAddToMyDaySectionController: TPTableItemSectionController{
    
    /// 添加到我的一天
    lazy var addToMyDayCellItem: TodoTaskEditTableCellItem = { [weak self] in
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "todo_task_addToMyDay_24"
        cellItem.updater = {
            self?.updateAddToMyDayCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.toggleAddToMyDay()
        }
        
        cellItem.didClickRightButton = { _ in
            self?.setAddToMyDay(false)
        }
        
        return cellItem
    }()

    let task: TodoTask
    
    init(task: TodoTask) {
        self.task = task
        super.init()
        self.cellItems = [addToMyDayCellItem]
        self.setupSeparatorFooterItem()
    }
    
    private func updateAddToMyDayCellItem() {
        let isActive = task.isAddedToMyDay
        let color = isActive ? addToMyDayCellItem.activeColor : addToMyDayCellItem.normalColor
        addToMyDayCellItem.isActive = isActive
        if isActive {
            addToMyDayCellItem.title = resGetString("Added to My Day")
        } else {
            addToMyDayCellItem.title = resGetString("Add to My Day")
        }
    }
    
    private func toggleAddToMyDay() {
        setAddToMyDay(!task.isAddedToMyDay)
    }
    
    private func setAddToMyDay(_ isAddedToMyDay: Bool) {
        guard task.isAddedToMyDay != isAddedToMyDay else {
            return
        }
        
        todo.updateTask(task, isAddedToMyDay: isAddedToMyDay)
        adapter?.reloadCell(forItem: addToMyDayCellItem, with: .none)
    }
    
}
