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
    
    /// 添加处理更新器
    func addUpdater(_ updater: AnyObject, for option: TodoUpdaterOption = .all) {
        if option.contains(.list) {
            userListManager.updater.addDelegate(updater)
        }
        
//        if option.contains(.task) {
//            taskManager.updater.addDelegate(updater)
//        }
//
//        if option.contains(.step) {
//            stepManager.updater.addDelegate(updater)
//        }
//
//        if option.contains(.tag) {
//            tagManager.updater.addDelegate(updater)
//        }      
    }
    
    // MARK: - 列表
    /// 新建列表
    func createList(with editingList: TodoEditingList, parent: TodoList?) {
        userListManager.createList(with: editingList, parent: parent)
    }
    
    /// 更新列表信息
    func updateList(_ list: TodoList, with editingList: TodoEditingList, parent: TodoList?) {
        userListManager.updateList(list, with: editingList, parent: parent)
    }
}
