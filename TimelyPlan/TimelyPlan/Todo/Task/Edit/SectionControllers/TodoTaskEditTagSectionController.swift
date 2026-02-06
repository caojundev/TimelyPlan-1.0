//
//  TodoTaskEditTagSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/10.
//

import Foundation

class TodoTaskEditTagSectionController: TPTableItemSectionController{
 
    /// 标签
    lazy var tagCellItem: TodoTaskEditTableCellItem = { [weak self] in
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "todo_task_tag_24"
        cellItem.updater = {
            self?.updateTagCellItem()
        }
        
        cellItem.didClickRightButton = { _ in
            self?.selectTags(nil)
        }
        
        return cellItem
    }()

    let task: TodoTask
    
    init(task: TodoTask) {
        self.task = task
        super.init()
        self.cellItems = [tagCellItem]
        self.setupSeparatorFooterItem()
    }
    
    private func updateTagCellItem() {
        if let tags = task.tags, tags.count > 0 {
            let format: String
            if tags.count > 1 {
                format = resGetString("%ld tags")
            } else {
                format = resGetString("%ld tag")
            }
            
            tagCellItem.title = String(format: format, tags.count)
            tagCellItem.isActive = true
        } else {
            tagCellItem.title = resGetString("Tag")
            tagCellItem.isActive = false
        }
    }
    
    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        editTags()
    }

    private func editTags() {
        let selectedTags = task.tags as? Set<TodoTag>
        TodoTaskController.editTags(selectedTags) {[weak self] newTags in
            self?.selectTags(newTags)
        }
    }
    
    private func selectTags(_ tags: Set<TodoTag>?) {
        todo.updateTask(task, tags: tags)
        reloadData()
    }
    
    func reloadData() {
        adapter?.reloadCell(forItem: tagCellItem, with: .none)
    }
}
