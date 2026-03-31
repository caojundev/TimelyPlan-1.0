//
//  TodoUserListManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/5.
//

import Foundation
import CoreData

class TodoUserListManager {
    
    /// 列表处理更新器
    let updater = TodoListProcessorUpdater()
    
    // MARK: - 用户列表数组
    func fetchUserLists(with stateProvider: ExpansionStateProviding,
                        completion: @escaping([TodoList]?) -> Void) {
        CDTodoList.fetchTopLists { results in
            guard let userLists = results?.userLists else {
                completion(nil)
                return
            }
            
            let lists = userLists.flattenItems(with: stateProvider)
            completion(lists as? [TodoList])
        }
    }
    
    // MARK: - 列表操作
    /// 新建列表
    func createList(with editList: TodoEditingList, parent: TodoList?) {
        let content = CDTodoList.newList(with: editList, parent: parent)
        let list = TodoList(content: content)
        HandyRecord.save()
        updater.didCreateTodoList(list)
    }
    
    /// 更新列表信息
    func updateList(_ list: TodoList, with editingList: TodoEditingList, parent: TodoList?) {
        if list.parent?.identifier != parent?.identifier {
            moveList(list, to: parent) /// 移动列表
        }

        if list.isSameEditingList(as: editingList) {
            return
        }

        if CDTodoList.update(list: list, with: editingList) {
            list.update(with: editingList)
            HandyRecord.save()
            updater.didUpdateTodoList(list)
        }
    }

    /// 移动列表
    func moveList(_ list: TodoList, to parent: TodoList?) {
        guard CDTodoList.moveList(list, to: parent) else {
            return
        }
        
        let fromParent = list.parent
        if let parent = parent {
            parent.addSublist(list)
        } else {
            /// 从原父清单移出
            list.parent?.removeSublist(list)
        }
        
        HandyRecord.save()
        updater.didMoveTodoLists([list], from: fromParent)
    }
    
    /// 删除列表
    func deleteList(_ list: TodoList) {
        /*
        let isTopList = list.parent == nil
        let sublists = list.flattenOrderedSubItems { _ in
            return true
        } as! [TodoList]
        
        let deleteLists = [list] + sublists
        for deleteList in deleteLists {
            moveAllTasksToTrash(in: deleteList)
            NSManagedObjectContext.defaultContext.delete(deleteList)
        }
        
        if isTopList {
            updateTopLists()
        }
        
        updater.didDeleteTodoLists(deleteLists)
        todo.save()
        */
    }
    
    

    /// 执行插入操作
    func reorderList(in lists: [TodoList], fromIndex: Int, toIndex: Int, depth: Int) {
        /*
        let list = lists[fromIndex]
        let fromDepth = list.depth
        lists.reorderItem(fromIndex: fromIndex, toIndex: toIndex, depth: depth)
        let toDepth = list.depth
        if fromDepth == 0 || toDepth == 0 {
            /// 顶层列表改变，更新顶层列表
            updateTopLists()
        }
        
        updater.didReorderTodoList(list)
        todo.save()
        */
    }
    
    
    /// 将所有任务移到废纸篓
//    func moveAllTasksToTrash(in list: TodoList) {
//        guard let tasks = list.tasks as? Set<TodoTask>, tasks.count > 0 else {
//            return
//        }
//
//        for task in tasks {
//            task.isRemoved = true
//        }
//    }
    
    /// 解散列表
    func ungroupList(_ list: TodoList) {
        /*
        let parentList = list.parent
        var parentSublists: [TodoList]
        if let parentList = parentList {
            parentSublists = parentList.orderedSubLists
        } else {
            parentSublists = topLists ?? []
        }
        
        guard let index = parentSublists.firstIndex(of: list) else {
            return
        }
        
        let sublists = list.orderedSubLists
        /// 移除当前列表所有子列表
        list.removeAllSublists()
        
        /// 添加到当前列表父列表
        if let parentList = parentList {
            parentList.addToSubLists(Set(sublists) as NSSet)
        }
        
        parentSublists.insert(contentsOf: sublists, at: index + 1)
        parentSublists.updateOrders() /// 更新顺序因子
        if parentList == nil {
            updateTopLists()
        }
        
        updater.didMoveTodoLists(sublists, from: list)
        todo.save()
        */
    }
}
