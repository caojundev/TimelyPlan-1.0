//
//  TodoSmartListViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/18.
//

import Foundation

class TodoSmartListViewModel: TodoBaseListViewModel {
    
    /// 数目改变
    var countDidChange: (([TodoSmartList]) -> Void)?
}


extension TodoSmartListViewModel: TodoTaskProcessorDelegate {

    private func changeCount() {
        let lists = TodoSmartList.allLists
        counter.invalidateCount(for: lists)
        countDidChange?(lists)
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        changeCount()
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        changeCount()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        changeCount()
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        let lists = [TodoSmartList.trash]
        counter.invalidateCount(for: lists)
        countDidChange?(lists)
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        let changeInfo = TodoTaskChangeInfo(task: task, change: change)
        self.didUpdateTodoTasks(with: [changeInfo])
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        changeCount()
    }
}
