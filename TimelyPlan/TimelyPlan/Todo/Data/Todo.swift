//
//  Todo.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/30.
//

import Foundation

class Todo {
    
    /// 用户列表管理器
    private let userListManager = TodoUserListManager()
    
    /// 标签管理器
    private let tagManager = TodoTagManager()
    
    /// 添加处理更新器
    func addUpdater(_ updater: AnyObject, for option: TodoUpdaterOption = .all) {
        if option.contains(.list) {
            userListManager.updater.addDelegate(updater)
        }
        
        if option.contains(.tag) {
            tagManager.updater.addDelegate(updater)
        }
        
//        if option.contains(.task) {
//            taskManager.updater.addDelegate(updater)
//        }
//
//        if option.contains(.step) {
//            stepManager.updater.addDelegate(updater)
//        }
   
    }
    
    // MARK: - 列表处理
    
    /// 新建列表
    func createList(with editingList: TodoEditingList, parent: TodoList?) {
        userListManager.createList(with: editingList, parent: parent)
    }
    
    /// 更新列表信息
    func updateList(_ list: TodoList, with editingList: TodoEditingList, parent: TodoList?) {
        userListManager.updateList(list, with: editingList, parent: parent)
    }
    
    /// 移动列表
    func moveList(_ list: TodoList, to parent: TodoList?) {
        userListManager.moveList(list, to: parent)
    }
    
    func reorderList(in lists: [TodoList], fromIndex: Int, toIndex: Int, depth: Int) {
        userListManager.reorderList(in: lists, fromIndex: fromIndex, toIndex: toIndex, depth: depth)
    }
    
    /// 解散列表
    func ungroupList(_ list: TodoList) {
        userListManager.ungroupList(list)
    }
    
    /// 删除列表
    func deleteList(_ list: TodoList) {
        userListManager.deleteList(list)
    }
    
    
    // MARK: - 获取标签
    func getTags() -> [TodoTag] {
        return tagManager.getTags()
    }
    
    /// 判断标签名称是否已存在
    func isTagExist(with name: String) -> Bool {
        return tagManager.isTagExist(with: name)
    }
    
    /// 搜索标签
    func searchTags(containText text: String,
                     completion:(@escaping([TodoTag]?) -> Void)) {
        tagManager.fetchTags(containText: text, completion: completion)
    }
    
    // MARK: - 标签处理
    /// 新建标签
    func createTag(with editingTag: TodoEditingTag) {
        tagManager.createTag(with: editingTag)
    }
    
    /// 删除标签
    func deleteTag(_ tag: TodoTag) {
        tagManager.deleteTag(tag)
    }
    
    /// 更新标签信息
    func updateTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        tagManager.updateTag(tag, with: editingTag)
    }

    /// 重新排序标签
    func reorderTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        return tagManager.reorderTag(in: tags, fromIndex: fromIndex, toIndex: toIndex)
    }
 
}
