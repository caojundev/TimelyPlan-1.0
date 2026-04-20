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
    
    private(set) var types: [TodoSmartListType]
    
    init(types: [TodoSmartListType]) {
        self.types = types
        super.init()
        todo.addUpdater(self)
    }
}


extension TodoSmartListViewModel: TodoTaskProcessorDelegate {

    private func changeCount(of listTypes: [TodoSmartListType] = TodoSmartListType.allCases) {
        var lists = [TodoSmartList]()
        for listType in listTypes {
            if types.contains(listType) {
                let list = TodoSmartList(type: listType)
                lists.append(list)
            }
        }
        
        counter.invalidateCount(for: lists)
        countDidChange?(lists)
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        changeCount()
    }
    
    func didMoveTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        var bInboxChanged: Bool = false
        for task in tasks {
            if task.list == nil {
                bInboxChanged = true
                break
            }
        }
        
        if !bInboxChanged, list == nil {
            bInboxChanged = true
        }
        
        if bInboxChanged {
            changeCount(of: [.inbox])
        }
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        changeCount()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        changeCount()
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        changeCount(of: [.trash])
    }
    
    func didEmptyTrash() {
        changeCount(of: [.trash])
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        let changeInfo = TodoTaskChangeInfo(task: task, change: change)
        self.didUpdateTodoTasks(with: [changeInfo])
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        changeCount()
    }
}
