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
    
    override init(interactor: TodoTaskEditInteractor) {
        super.init(interactor: interactor)
        self.setupSeparatorFooterItem()
        self.cellItems = [progressCellItem]
    }
    
    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        TodoTaskController.editProgress(task.progress) {[weak self] newProgress in
            self?.didEndEditingProgress(newProgress)
        }
    }
    
    private func updateProgressCellItem() {
        if let progress = task.progress, progress.isValid {
            progressCellItem.title = progress.info
            progressCellItem.isActive = true
        } else {
            progressCellItem.title = resGetString("Progress")
            progressCellItem.isActive = false
        }
    }
    
    private func didEndEditingProgress(_ editProgress: TodoEditProgress?) {
        interactor.setProgress(editProgress)
        adapter?.reloadCell(forItem: progressCellItem, with: .none)
    }
}
