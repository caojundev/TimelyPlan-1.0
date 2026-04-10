//
//  TodoTaskEditTagSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/10.
//

import Foundation

class TodoTaskEditTagSectionController: TodoTaskEditBaseSectionController {
 
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

    override init(interactor: TodoTaskEditInteractor) {
        super.init(interactor: interactor)
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
        var currentTags: Set<TodoTag>?
        if let tags = task.tags {
            currentTags = Set(tags)
        }
    
        TodoTaskController.editTags(currentTags) {[weak self] newTags in
            self?.selectTags(newTags)
        }
    }
    
    private func selectTags(_ tags: Set<TodoTag>?) {
        interactor.setTags(tags)
        reloadData()
    }
    
    func reloadData() {
        adapter?.reloadCell(forItem: tagCellItem, with: .none)
    }
}
