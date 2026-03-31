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
        editList(nil, parent: parent) { editingList, parent in
            todo.createList(with: editingList, parent: parent)
        }
    }
    
    /// 编辑列表
    public func editList(_ list: TodoList){
        editList(list, parent: list.parent) { editingList, parent in
            todo.updateList(list, with: editingList, parent: parent)
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
    
    // MARK: - 删除
    /// 弹窗确认删除列表
    func deleteList(_ list: TodoList) {
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        let listName = list.name ?? "Untitled"
        let format = resGetString("\"%@\" will be permanently deleted. Sure to delete?")
        let message = String(format: format, listName)
        let alertController = TPAlertController(title: resGetString("Delete"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }

    
    // MARK: - 移动
    func moveList(_ list: TodoList) {
        let allowMaxDepth = TodoList.parentMaxDepth(for: list)
        let vc = TodoParentListPickerViewController(list: list.parent,
                                                    allowMaxDepth: allowMaxDepth)
        vc.disabledLists = [list]
        vc.didSelectList = { moveToList in
            todo.moveList(list, to: moveToList)
        }

        vc.showAsNavigationRoot()
    }
    
    // MARK: - 解散列表
    func ungroupList(_ list: TodoList) {
        let ungroupAction = TPAlertAction(type: .destructive, title: resGetString("Ungroup")) { action in
//            todo.ungroupList(list)
        }
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        let format: String = resGetString("Are you sure to ungroup list \"%@\" ?")
        let listName = list.name ?? "Untitled"
        let message = String(format: format, listName)
        let alertController = TPAlertController(title: resGetString("Ungroup List"),
                                                message: message,
                                                actions: [cancelAction, ungroupAction])
        alertController.show()
    }
    
}
