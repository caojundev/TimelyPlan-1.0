//
//  TodoTaskEditMoreMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/8.
//

import Foundation

class TodoTaskEditMoreMenuController: TPBaseMenuController<TodoTaskActionType> {
    
    /// 菜单作用的任务
    let task: TodoTask
    
    override func allowMenuActionTypes() -> [TodoTaskActionType] {
        return [.trash]
    }
    
    init(task: TodoTask) {
        self.task = task
        super.init()
        self.preferredPosition = .topLeft
    }
}

