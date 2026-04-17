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
    
    // MARK: - 获取列表
    func fetchTopLists(completion: @escaping([TodoList]?) -> Void) {
        return CDTodoList.fetchTopLists { results in
            completion(results?.userLists)
        }
    }
    
    func getTopLists() -> [TodoList]? {
        return CDTodoList.getTopLists()?.userLists
    }
    
    func getUserList(of identifier: String) -> TodoList? {
        guard let cdList = CDTodoList.getItem(withIdentifier: identifier) else {
            return nil
        }
        
        #warning("父列表未设置")
        return TodoList(content: cdList)
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

        if CDTodoList.updateList(list, with: editingList) {
            HandyRecord.save()
            updater.didUpdateTodoList(list)
        }
    }
    
    /// 更新列表布局
    func updateList(_ list: TodoList, layoutType: TodoListLayoutType) {
        if CDTodoList.updateList(list, layoutType: layoutType) {
            HandyRecord.save()
            updater.didUpdateTodoList(list)
        }
    }

    /// 移动列表
    func moveList(_ list: TodoList, to parent: TodoList?) {
        guard CDTodoList.moveList(list, to: parent) else {
            return
        }
        
        HandyRecord.save()
        updater.didMoveTodoList(list, to: parent)
    }
    
    /// 解散列表
    func ungroupList(_ list: TodoList) {
        guard CDTodoList.ungroupList(list) else {
            return
        }
        
        HandyRecord.save()
        updater.didUngroupList(list)
    }
    
    /// 删除列表
    func deleteList(_ list: TodoList) {
        if CDTodoList.deleteList(list) {
            HandyRecord.save()
            updater.didDeleteTodoLists([list])
        }
    }
    
    /// 执行插入操作
    func reorderList(in lists: [TodoList], fromIndex: Int, toIndex: Int, depth: Int) {
        guard CDTodoList.reorderList(in: lists,
                                     fromIndex: fromIndex,
                                     toIndex: toIndex,
                                     depth: depth) else {
            return
        }
        
        HandyRecord.save()
        updater.didReorderTodoList(lists[fromIndex])
    }

}
