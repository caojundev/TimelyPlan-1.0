//
//  TodoTaskEditMyDaySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/9.
//

import Foundation

class TodoTaskEditMyDaySectionController: TodoTaskEditBaseSectionController {
    
    /// 添加到我的一天
    lazy var myDayCellItem: TodoTaskEditTableCellItem = { [weak self] in
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "todo_task_addToMyDay_24"
        cellItem.updater = {
            self?.updateMyDayCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editMyDay()
        }
        
        cellItem.didClickRightButton = { _ in
            self?.setAddToMyDay(false)
        }
        
        return cellItem
    }()

    override var cellItems: [TPBaseTableCellItem]? {
        get {
            if task.isAddedToMyDay {
                return [myDayCellItem]
            }
            
            return nil
        }
        
        set {}
    }
    
    override init(interactor: TodoTaskEditInteractor) {
        super.init(interactor: interactor)
    }
    
    private func updateMyDayCellItem() {
        let isActive = task.isAddedToMyDay
        myDayCellItem.isActive = isActive
        if isActive {
            myDayCellItem.title = resGetString("Added to My Day")
        } else {
            myDayCellItem.title = resGetString("Add to My Day")
        }
        
        setSeparatorHidden(!isActive)
    }

    private func setAddToMyDay(_ isAddedToMyDay: Bool) {
        interactor.setAddedToMyDay(isAddedToMyDay)
        adapter?.reloadCell(forItem: myDayCellItem, with: .none)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .automatic)
    }

    func editMyDay() {
        setAddToMyDay(!task.isAddedToMyDay)
    }
    
}
