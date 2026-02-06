//
//  TodoListController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/2.
//

import Foundation

class TodoListController {
    
    /// 新建列表
    public func createNewList(in folder: TodoFolder? = nil) {
        editList(nil, folder: folder) { editList, editFolder in
            todo.createList(with: editList, in: editFolder)
        }
    }
    
    /// 编辑列表
    public func editList(_ list: TodoList){
        editList(list, folder: list.folder) { editList, editFolder in
            todo.updateList(list, with: editList, folder: editFolder)
        }
    }
    
    private func editList(_ list: TodoList?,
                          folder: TodoFolder?,
                          completion: @escaping(TodoEditList, TodoFolder?) -> Void) {
        let vc = TodoListEditViewController(list: list, folder: folder)
        vc.didEndEditing = completion
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 移动列表
    func moveList(_ list: TodoList) {
        let vc = TodoFolderSelectViewController(folder: list.folder)
        vc.didSelectFolder = { folder in
            todo.moveList(list, to: folder)
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 弹窗确认删除列表
    func deleteList(_ list: TodoList) {
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            todo.deleteList(list)
        }
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        let listName = list.name ?? "Untitled"
        let format = resGetString("\"%@\" will be permanently deleted. Sure to delete?")
        let message = String(format: format, listName)
        let alertController = TPAlertController(title: resGetString("Delete"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }

    /// 清空废纸篓
    func emptyTrash() {
        let confirmAction = TPAlertAction(type: .destructive, title: resGetString("Confirm")) { action in
            todo.emptyTrash()
        }
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        let message = resGetString("Are you sure to delete all tasks in trash?")
        let alertController = TPAlertController(title: resGetString("Empty Trash"),
                                                message: message,
                                                actions: [cancelAction, confirmAction])
        alertController.show()
    }
}
