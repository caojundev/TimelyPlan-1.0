//
//  TodoUserListController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/2.
//

import Foundation

class TodoUserListController {
    
    // MARK: - 编辑
    /// 新建列表
    public func createList(parent: TodoList? = nil) {
        editList(nil, parent: parent) { editList, parent in
//            todo.createList(with: editList, parent: parent)
        }
    }
    
    /// 编辑列表
    public func editList(_ list: TodoList){
        editList(list, parent: list.parent) { editList, parent in
//            todo.updateList(list, with: editList, parent: parent)
        }
    }
    
    private func editList(_ list: TodoList?,
                          parent: TodoList?,
                          completion: @escaping(TodoEditingList, TodoList?) -> Void) {
        let vc = TodoListEditViewController(list: list, parent: parent)
        vc.didEndEditing = completion
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
}
