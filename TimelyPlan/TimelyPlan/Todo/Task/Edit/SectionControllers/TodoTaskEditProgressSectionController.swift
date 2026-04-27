//
//  TodoTaskEditProgressSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/6.
//

import Foundation
import UIKit

class TodoTaskEditProgressSectionController: TodoTaskEditBaseSectionController {
 
    lazy var progressCellItem: TodoTaskEditTableCellItem = { [weak self] in
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "todo_task_progress_24"
        cellItem.didClickRightButton = { _ in
            self?.didEndEditingProgress(nil)
        }
        
        cellItem.updater = {
            self?.updateProgressCellItem()
        }
        
        return cellItem
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            if let progress = task.progress, progress.isValid {
                return [progressCellItem]
            }
            
            return nil
        }
        
        set {}
    }
    
    override init(interactor: TodoTaskEditInteractor) {
        super.init(interactor: interactor)
    }
    
    func editProgress() {
        TodoTaskController.editProgress(task.progress) {[weak self] newProgress in
            self?.didEndEditingProgress(newProgress)
        }
    }
    
    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        editProgress()
    }
    
    private func updateProgressCellItem() {
        if let progress = task.progress, progress.isValid {
            progressCellItem.title = progress.info
            progressCellItem.isActive = true
            setSeparatorHidden(false)
        } else {
            progressCellItem.title = resGetString("Progress")
            progressCellItem.isActive = false
            setSeparatorHidden(true)
        }
    }
    
    private func didEndEditingProgress(_ editProgress: TodoEditProgress?) {
        interactor.setProgress(editProgress)
        adapter?.reloadCell(forItem: progressCellItem, with: .none)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .automatic)
    }
}
