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
    
    private(set) var topLists: [TodoList]?
    private var listIndex: [String: TodoList] = [:]
    
    init() {
        self.refreshTopLists()
    }
    
    func refreshTopLists() {
        if let cdTopLists = CDTodoList.getTopLists() {
            topLists = cdTopLists.toLists
        } else {
            topLists = []
        }
        
        rebuildIndex()
    }
    
    // MARK: - Index
    
    /// 重建索引
    private func rebuildIndex() {
        listIndex.removeAll()
        indexLists(topLists)
    }
    
    /// 递归索引清单
    private func indexLists(_ lists: [TodoList]?) {
        guard let lists = lists else { return }
        
        for list in lists {
            listIndex[list.identifier] = list
            indexLists(list.sublists)
        }
    }

    // MARK: - 获取清单
    
    /// 根据标识符获取单个清单
     func getUserList(of identifier: String) -> TodoList? {
         return listIndex[identifier]
     }
     
     /// 根据多个标识符批量获取清单
     func getUserLists(of identifiers: [String]) -> [TodoList]? {
         let lists = identifiers.compactMap { listIndex[$0] }
         return lists.isEmpty ? nil : lists
     }
    
    func fetchLists(containText text: String, completion: @escaping ([TodoList]?) -> Void) {
        guard let lists = topLists?.flattenItems() as? [TodoList] else {
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let results = lists.filter {
                $0.name?.localizedCaseInsensitiveContains(text) ?? false
            }
            
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    // MARK: - 列表操作
    /// 新建列表
    func createList(with editList: TodoEditingList, parent: TodoList?) {
        let onTop = TodoSetting.shared.addListOnTop
        let content = CDTodoList.newList(with: editList, parent: parent, onTop: onTop)
        HandyRecord.save()
        refreshTopLists()
        if let list = TodoList(content: content) {
            updater.didCreateTodoList(list)
        }
    }
    
    /// 更新列表信息
    func updateList(_ list: TodoList, with editingList: TodoEditingList, parent: TodoList?) {
        if list.parent?.identifier != parent?.identifier {
            moveList(list, to: parent) /// 移动列表
        }

        if CDTodoList.updateList(list, with: editingList) {
            updater.didUpdateTodoList(list, with: editingList)
//            list.update(with: editingList)
            HandyRecord.save()
        }
    }
    
    /// 更新列表布局
    func updateList(_ list: TodoList, layoutType: TodoListLayoutType) {
        var editingList = list.editingList
        guard editingList.layoutType != layoutType else {
            return
        }
        
        editingList.layoutType = layoutType
        if CDTodoList.updateList(list, with: editingList) {
            updater.didUpdateTodoList(list, with: editingList)
//            list.update(with: editingList)
            HandyRecord.save()
        }
    }

    /// 移动列表
    func moveList(_ list: TodoList, to parent: TodoList?) {
        guard CDTodoList.moveList(list, to: parent) else {
            return
        }
        
        HandyRecord.save()
        refreshTopLists()
        updater.didMoveTodoList(list, to: parent)
    }
    
    /// 解散列表
    func ungroupList(_ list: TodoList) {
        guard CDTodoList.ungroupList(list) else {
            return
        }
        
        HandyRecord.save()
        refreshTopLists()
        updater.didUngroupList(list)
    }
    
    /// 删除列表
    func deleteList(_ list: TodoList) {
        if CDTodoList.deleteList(list) {
            HandyRecord.save()
            refreshTopLists()
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
        refreshTopLists()
        updater.didReorderTodoList(lists[fromIndex])
    }

}
