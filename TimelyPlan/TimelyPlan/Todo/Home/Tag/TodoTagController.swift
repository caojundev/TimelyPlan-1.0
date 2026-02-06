//
//  TodoTagController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/29.
//

import Foundation
import UIKit

class TodoTagController {
    
    func performMenuAction(with type: TodoTagMenuActionType, for tag: TodoTag) {
        switch type {
        case .edit:
            editTag(tag)
        case .delete:
            deleteTag(tag)
        }
    }
    
    // MARK: - 新建 / 编辑标签
    
    /// 新建标签
    func createTag() {
        showTagEditViewController(with: nil) { editTag in
            guard let name = editTag.name, name.count > 0 else {
                return false
            }
            
            if todo.isTagExist(with: name) {
                self.showTagExistMessage()
                return false
            } else {
                todo.createTag(with: editTag)
                return true
            }
        }
    }
    
    func createTag(withName name: String, color: UIColor) {
        if todo.isTagExist(with: name) {
            showTagExistMessage()
        } else {
            let editTag = TodoEditTag(name: name, color: color)
            todo.createTag(with: editTag)
        }
    }
    
    /// 编辑列表
    func editTag(_ tag: TodoTag){
        showTagEditViewController(with: tag.editTag) { editTag in
            todo.updateTag(tag, with: editTag)
            return true
        }
    }
    
    private func showTagExistMessage() {
        let message = resGetString("This tag already exists")
        TPFeedbackQueue.common.postFeedback(text: message, position: .middle)
    }
    
    // MARK: - 删除
    /// 弹窗确认删除列表
    func deleteTag(_ tag: TodoTag) {
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            todo.deleteTag(tag)
        }
        
        let cancelAction = TPAlertAction.cancel
        let format = resGetString("\"%@\" will be permanently deleted. Sure to delete?")
        let tagName = tag.name ?? resGetString("Untitled")
        let message = String(format: format, tagName)
        let alertController = TPAlertController(title: resGetString("Delete Tag"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
 
    // MARK: - Helpers
    /// 标签编辑视图控制器
    private func showTagEditViewController(with tag: TodoEditTag?, completion: ((TodoEditTag) -> Bool)?){
        let vc = TodoTagEditViewController(tag: tag)
        vc.completion = completion
        vc.popoverShowAsNavigationRoot()
    }
    
}
