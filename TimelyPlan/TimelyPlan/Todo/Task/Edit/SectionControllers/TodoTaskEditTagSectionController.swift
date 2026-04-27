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
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            if let tags = task.tags, tags.count > 0 {
                return [tagCellItem]
            }
            
            return nil
        }
        
        set {}
    }

    override init(interactor: TodoTaskEditInteractor) {
        super.init(interactor: interactor)
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
            setSeparatorHidden(false)
        } else {
            tagCellItem.title = resGetString("Tag")
            tagCellItem.isActive = false
            setSeparatorHidden(true)
        }
    }
    
    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        editTag()
    }

    private func selectTags(_ tags: Set<TodoTag>?) {
        interactor.setTags(tags)
        adapter?.reloadCell(forItem: tagCellItem, with: .none)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .automatic)
    }
    
    func editTag() {
        var currentTags: Set<TodoTag>?
        if let tags = task.tags {
            currentTags = Set(tags)
        }
    
        TodoTaskController.editTags(currentTags) {[weak self] newTags in
            self?.selectTags(newTags)
        }
    }
    
}
