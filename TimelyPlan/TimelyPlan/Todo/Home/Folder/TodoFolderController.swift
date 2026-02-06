//
//  TodoFolderController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/2.
//

import Foundation

class TodoFolderController {
    
    /// 创建新目录
    func createNewFolder() {
        let title = resGetString("New Folder")
        let vc = TPTextFieldAlertController(title: title) { name in
            guard let name = name else {
                return
            }
            
            todo.createFolder(with: name)
        }
        
        vc.placeholder = resGetString("Enter folder name")
        vc.popoverShow()
    }
    
    /// 编辑目录
    func editFolder(_ folder: TodoFolder) {
        let title = resGetString("Edit Folder")
        let vc = TPTextFieldAlertController(title: title) { name in
            guard let name = name, name.count > 0 else {
                return
            }
            
            todo.updateFolder(folder, with: name)
        }
        
        vc.text = folder.name
        vc.placeholder = resGetString("Enter folder name")
        vc.popoverShow()
    }
    
    /// 解散列表
    func ungroupFolder(_ folder: TodoFolder) {
        todo.ungroupFolder(folder)
    }
    
    func deleteFolder(_ folder: TodoFolder) {
        todo.deleteFolder(folder)
    }
}
