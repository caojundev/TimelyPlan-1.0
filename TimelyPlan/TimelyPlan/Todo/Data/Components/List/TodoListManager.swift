//
//  TodoListManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/1.
//

import Foundation
import CoreData

struct TodoListKey {
    static var identifier = "identifier"
    static var name = "name"
    static let order = "order"
    static let folder = "folder"
}

class TodoListManager {
    
    /// 列表处理更新器
    let updater = TodoListProcessorUpdater()
    
    /// 根列表
    private(set) var rootLists: [TodoList]?
    
    init() {
        updateRootLists()
    }
    
    private func updateRootLists() {
        rootLists = TodoListManager.getRootLists()
    }
    
    // MARK: - Processor

    /// 根据编辑列表信息在目录中创建清单
    func createList(with editList: TodoEditList, in folder: TodoFolder?) {
        let list = TodoList.newList(with: editList, folder: folder)
        if folder == nil {
            rootLists?.addList(list)
        }
        
        updater.didCreateTodoList(list)
        todo.save()
    }
    
    /// 更新列表信息
    func updateList(_ list: TodoList, with editList: TodoEditList, folder: TodoFolder?) {
        if list.folder != folder {
            /// 移动列表
            moveList(list, to: folder)
        }

        if list.isSame(as: editList) {
            return
        }

        list.update(with: editList)
        updater.didUpdateTodoList(list)
        todo.save()
    }
    
    /// 移动列表到新目录
    func moveList(_ list: TodoList, to folder: TodoFolder?, shouldSave: Bool = true) {
        let fromFolder = list.folder
        if folder == fromFolder {
            return
        }
        
        if let folder = folder {
            if fromFolder == nil {
                /// 列表原来为根列表，从数组删除
                rootLists?.remove(list)
            }
            
            folder.addList(list)
        } else {
            /// 移动到根目录
            list.folder = nil
            rootLists?.addList(list)
        }
        
        updater.didMoveTodoList(list, from: fromFolder)
        if shouldSave {
            todo.save()
        }
    }

    /// 删除列表
    func deleteList(_ list: TodoList) {
        let folder = list.folder
        if folder == nil {
            rootLists?.remove(list)
        }

        moveAllTasksToTrash(in: list)
        folder?.removeList(list)
        NSManagedObjectContext.defaultContext.delete(list)
        updater.didDeleteTodoList(list, from: folder)
        todo.save()
    }
    
    /// 将所有任务移到废纸篓
    func moveAllTasksToTrash(in list: TodoList) {
        guard let tasks = list.tasks as? Set<TodoTask>, tasks.count > 0 else {
            return
        }
        
        for task in tasks {
            task.isRemoved = true
        }
    }
    
    /// 重新排序列表
    func reorderList(in items: [ListDiffable], fromIndex: Int, toIndex: Int, depth: Int) {
        guard let list = items[fromIndex] as? TodoList else {
            return
        }
        
        if depth == 0 {
            if list.folder != nil {
                moveList(list, to: nil, shouldSave: false)
            }
        } else if depth == 1 {
            if let folder = items.moveFolder(to: toIndex, from: fromIndex, depth: depth) as? TodoFolder {
                moveList(list, to: folder, shouldSave: false)
            }
        }
        
        guard var items = items as? [Sortable] else {
            return
        }
        
        items.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        items.updateOrders()
        rootLists = rootLists?.orderedElements()
        updater.didReorderTodoList(list)
        todo.save()
    }
    
    // MARK: - Provider
    
    /// 根据文本内容获取匹配的待办事项列表
    static func fetchLists(containText text: String, completion:(@escaping([TodoList]?) -> Void)) {
        let condition: PredicateCondition = (TodoListKey.name, .contains(text))
        let predicate = NSPredicate.predicate(with: condition)
        TodoList.fetchAll(withPredicate: predicate, sortedBy: TodoListKey.order, ascending: true) { results in
            completion(results as? [TodoList])
        }
    }
    
    /// 同步获取根清单
    static func getRootLists() -> [TodoList]? {
        let conditions: [PredicateCondition] = [(TodoListKey.folder, .isEmpty)]
        let predicate = conditions.andPredicate()
        let results: [TodoList]? = TodoList.findAll(with: predicate,
                                                    sortedBy: TodoListKey.order,
                                                    ascending: true,
                                                    in: .defaultContext)
        return results
    }
    
    /// 同步获取标识对应的清单数组
    static func getLists(with identifiers: [String]) -> [TodoList]? {
        let condition: PredicateCondition = (TodoListKey.identifier, .belongsTo(identifiers))
        let predicate = NSPredicate.predicate(with: condition)
        let results: [TodoList]? = TodoList.findAll(with: predicate,
                                                    sortedBy: TodoListKey.order,
                                                    ascending: true,
                                                    in: .defaultContext)
        return results
    }
}
