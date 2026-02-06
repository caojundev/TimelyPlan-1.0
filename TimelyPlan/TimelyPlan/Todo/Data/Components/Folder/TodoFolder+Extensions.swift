//
//  TodoFolder+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/28.
//

import Foundation

extension TodoFolder: Sortable {
    
    /// 目录中是否有列表
    var hasLists: Bool {
        guard let lists = lists else {
            return false
        }
        
        return lists.count > 0
    }
    
    /// 有序的列表数组
    var orderedLists: [TodoList]? {
        return lists?.orderedElements() as? [TodoList]
    }
    
    /// 根据名称新建目录
    static func newFolder(with name: String?) -> TodoFolder {
        let folder = TodoFolder.createEntity(in: .defaultContext)
        folder.identifier = NSUUID().uuidString
        folder.updateName(with: name)
        return folder
    }
    
    /// 更新目录名称
    func updateName(with name: String?) {
        self.name = name
    }
    
    // MARK: - 添加 / 删除列表
    func addList(_ list: TodoList) {
        let lists = lists?.allObjects as? [TodoList]
        let maxOrder = lists?.maxOrder ?? 0
        list.order = maxOrder + kOrderedStep
        self.addToLists(list)
    }
    
    func removeList(_ list: TodoList) {
        self.removeFromLists(list)
    }
    
    /// 移除目录内所有清单
    func removeAllLists() {
        guard let lists = self.lists else {
            return
        }
        
        self.removeFromLists(lists)
    }
    
}
