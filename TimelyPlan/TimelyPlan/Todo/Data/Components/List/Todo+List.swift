//
//  Todo+List.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/2.
//

import Foundation

extension Todo {
    
    /// 新建列表
    func createList(with editList: TodoEditList, in folder: TodoFolder?) {
        listManager.createList(with: editList, in: folder)
    }
    
    /// 更新列表信息
    func updateList(_ list: TodoList, with editList: TodoEditList, folder: TodoFolder?) {
        listManager.updateList(list, with: editList, folder: folder)
    }
    
    /// 移动列表至特定目录
    func moveList(_ list: TodoList, to folder: TodoFolder?) {
        listManager.moveList(list, to: folder)
    }
    
    /// 删除列表
    func deleteList(_ list: TodoList) {
        listManager.deleteList(list)
    }
    
    /// 重新排序列表
    func reorderList(in items: [ListDiffable], fromIndex: Int, toIndex: Int, depth: Int) {
        listManager.reorderList(in: items, fromIndex: fromIndex, toIndex: toIndex, depth: depth)
    }
    
    /// 按排序因子排列的列表数组
    func orderedLists() -> [TodoList] {
        var items: [Sortable] = folderManager.folders
        if let lists = listManager.rootLists {
            items.append(contentsOf: lists)
        }
        
        let orderedItems = items.sorted { $0.order < $1.order }
        var results: [TodoList] = []
        for item in orderedItems {
            if let folder = item as? TodoFolder {
                if let lists = folder.orderedLists {
                    results.append(contentsOf: lists)
                }
            } else if let list = item as? TodoList {
                results.append(list)
            }
        }

        return results
    }
    
    /// 异步获取名称包含特定文本的列表数组
    func fetchLists(containText text: String, completion:(@escaping([TodoList]?) -> Void)) {
        TodoListManager.fetchLists(containText: text, completion: completion)
    }
    

    /// 列表标识数组
    func getLists(with identifiers: [String]) -> [TodoList]? {
        TodoListManager.getLists(with: identifiers)
    }
}
