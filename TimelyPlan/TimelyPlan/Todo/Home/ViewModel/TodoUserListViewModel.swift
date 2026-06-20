//
//  TodoUserListViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/30.
//

import Foundation

enum TodoUserListChange {
case create(TodoList) /// 创建新列表
case update(TodoList) /// 更新列表
}

class TodoHomeUserListViewModel: TodoUserListViewModel {
    
    /// 区块是否展开
    var isExpanded: Bool {
        get {
            return TodoState.shared.isHomeListExpanded
        }
        
        set {
            TodoState.shared.isHomeListExpanded = newValue
        }
    }
    
}

class TodoUserListViewModel: TodoBaseListViewModel, ExpansionStateProviding {
    
    /// 数目改变
    var countDidChange: (([TodoListFeature]) -> Void)?
    
    /// 用户列表改变
    var userListDidChange: ((TodoUserListChange?) -> Void)?
    
    /// 顶层清单
    private var topLists: [TodoList]?
    
    let expansionState: ExpansionStateProviding
    
    init(expansionState: ExpansionStateProviding) {
        self.expansionState = expansionState
        super.init()
        TodoRepository.addUpdater(self)
    }
    
    // MARK: -
    func loadTopLists(with change: TodoUserListChange? = nil, completion: (() -> Void)? = nil) {
        topLists = TodoRepository.getTopLists()
        userListDidChange?(change)
        completion?()
    }
    
    private func lists(with stateProvier: ExpansionStateProviding) -> [TodoList] {
        guard let topLists = topLists else {
            return []
        }
        
        let lists = topLists.flattenItems(with: stateProvier) as? [TodoList]
        return lists ?? []
    }
    
    /// 获取用户列表数组
    func lists() -> [TodoList] {
        return lists(with: expansionState)
    }
    
    // MARK: - ExpansionStateProviding
    func isExpanded(_ item: Any) -> Bool {
        return expansionState.isExpanded(item)
    }
    
    func setExpended(_ isExpended: Bool, for item: Any) {
        expansionState.setExpended(isExpended, for: item)
    }
}

extension TodoUserListViewModel: TodoListProcessorDelegate {
    
    func didChangeRemoteTodoList(with results: EntityChangeResults<TodoList>?) {
        loadTopLists()
    }
    
    /// 添加新组时通知
    func didCreateTodoList(_ list: TodoList) {
        expandAllParent(of: list)
        loadTopLists(with: .create(list))
    }
    
    /// 更新列表信息通知
    func didUpdateTodoList(_ list: TodoList, with editingList: TodoEditingList) {
        loadTopLists(with: .update(list))
    }
    
    func didUngroupList(_ list: TodoList) {
        loadTopLists()
    }
    
    /// 删除列表时通知
    func didDeleteTodoLists(_ lists: [TodoList]) {
        loadTopLists()
    }
    
    /// 列表移动通知， parent为nil时表示移动到根目录
    func didMoveTodoList(_ list: TodoList, to parent: TodoList?) {
        if let parent = parent {
            expandAllParent(of: parent, includeCurrent: true)
        }
        
        loadTopLists()
    }

    /// 重新列表排序
    func didReorderTodoList(_ list: TodoList) {
        expandAllParent(of: list, includeCurrent: false)
        loadTopLists()
    }
}

extension TodoUserListViewModel: TodoTaskProcessorDelegate {
    
    func didChangeRemoteTodoTask(with results: EntityChangeResults<TodoTask>?) {
        guard let updated = results?.updated else {
            return
        }
        
        if let lists = updated.userListFeatures {
            counter.invalidateCount(for: lists)
            countDidChange?(lists)
        }
    }
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        if let list = list?.feature {
            counter.invalidateCount(for: list)
            countDidChange?([list])
        }
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        if let list = task.list {
            counter.invalidateCount(for: list)
            countDidChange?([list])
        }
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        if let lists = tasks.userListFeatures {
            counter.invalidateCount(for: lists)
            countDidChange?(lists)
        }
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        if let lists = tasks.userListFeatures {
            counter.invalidateCount(for: lists)
            countDidChange?(lists)
        }
    }
    
    func didMoveTodoTasks(_ tasks: [TodoTask], to section: TodoSectionFeature) {
        var lists = tasks.userListFeatures ?? []
        if let toList = section.list {
            lists.append(toList)
        }
        
        if lists.count > 0 {
            counter.invalidateCount(for: lists)
            countDidChange?(lists)
        }
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        let changeInfo = TodoTaskChangeInfo(task: task, change: change)
        self.didUpdateTodoTasks(with: [changeInfo])
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        var lists = [TodoListFeature]()
        for changeInfo in changeInfos {
            let change = changeInfo.change
            switch change {
            case .completed(_, _):
                if let list = changeInfo.task.list {
                    lists.append(list)
                }
            case .list(let oldValue, let newValue):
                if let oldList = oldValue {
                    lists.append(oldList)
                }
                
                if let newList = newValue {
                    lists.append(newList)
                }
                
            default:
                break
            }
        }
        
        if lists.count > 0 {
            counter.invalidateCount(for: lists)
            countDidChange?(lists)
        }
    }
}
