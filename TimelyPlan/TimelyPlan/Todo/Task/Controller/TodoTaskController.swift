//
//  TodoTaskController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/13.
//

import Foundation
import UIKit

class TodoTaskController {
    
    func performMenuAction(with type: TodoTaskActionType,
                           for tasks: [TodoTask],
                           sourceView: UIView,
                           completion: @escaping (()->Void)) {
        switch type {
        case .done:
            setCompleted(true, for: tasks, completion: completion)
        case .undone:
            setCompleted(false, for: tasks, completion: completion)
        case .move:
            moveTasks(tasks, completion: completion)
        case .date:
            break
        case .priority:
            editPriority(for: tasks, sourceView: sourceView, completion: completion)
        case .trash:
            moveToTrash(with: tasks, completion: completion)
        case .restore:
            confirmRestoration(for: tasks, completion: completion)
        case .shred:
            confirmDeletion(for: tasks, completion: completion)
        }
    }
    
    // MARK: - 编辑
    func editTask(_ task: TodoTask) {
        let editVC = TodoTaskEditViewController(task: task)
        let navigationController = UINavigationController(rootViewController: editVC)
        
        let configure = TPSlidePresentationConfigure()
        configure.automaticallyAdjustsForKeyboard = false
        configure.maskColor = Color(0x000000, 0.4)
        configure.direction = .right
        configure.regularCornerRadius = 16.0
        configure.compactCornerRadius = 0.0
        configure.presentPosition = .right
        configure.compactContentSize = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                              height: CGFloat.greatestFiniteMagnitude)
        configure.regularContentSize = CGSize(width: 320.0, height: .greatestFiniteMagnitude)
        configure.compactRoundingCorners = []
        configure.regularRoundingCorners = .allCorners
        configure.compactEdgeInsets = .zero
        configure.regularEdgeInsets = UIEdgeInsets(value: 10.0)
        let topVC = UIViewController.topPresented
        topVC?.slidePresent(navigationController,
                            configure: configure,
                            isInteractive: true,
                            animated: true,
                            completion: nil)
    }
    
    // MARK: - 完成任务
    func setCompleted(_ isCompleted: Bool, for tasks: [TodoTask], completion: (()->Void)? = nil) {
        todo.setCompleted(isCompleted, for: tasks)
        completion?()
    }
    
    // MARK: - 删除
    
    /// 弹窗确认删除列表
    func confirmDeletion(for task: TodoTask, completion: (()->Void)? = nil) {
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            todo.deleteTask(task)
            completion?()
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        let format = resGetString("\"%@\" will be permanently deleted.")
        let taskName = task.name ?? resGetString("Untitled")
        let message = String(format: format, taskName)
        let alertController = TPAlertController(title: resGetString("Delete Task"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    func confirmDeletion(for tasks: [TodoTask], completion: (()->Void)? = nil) {
        guard tasks.count > 0 else {
            return
        }
        
        /// 确认删除单个任务
        if tasks.count == 1 {
            confirmDeletion(for: tasks[0], completion: completion)
            return
        }
        
        /// 确认删除多个任务
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            todo.deleteTasks(tasks)
            completion?()
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        let format = resGetString("%ld tasks will be permanently deleted.")
        let message = String(format: format, tasks.count)
        let alertController = TPAlertController(title: resGetString("Delete Task"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    
    // MARK: - 从废纸篓恢复
    func confirmRestoration(for task: TodoTask, completion: (()->Void)? = nil) {
        let restoreAction = TPAlertAction(type: .normal,
                                         title: resGetString("Restore")) { action in
            todo.restoreTrashTask(task)
            completion?()
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        let message = resGetString("The task will be restored to its original list. Are you sure to restore?")
        let alertController = TPAlertController(title: resGetString("Restore Task"),
                                                message: message,
                                                actions: [cancelAction, restoreAction])
        alertController.show()
    }
    
    func confirmRestoration(for tasks: [TodoTask], completion: (()->Void)? = nil) {
        guard tasks.count > 0 else {
            return
        }
        
        if tasks.count == 1 {
            confirmRestoration(for: tasks[0], completion: completion)
            return
        }
        
        let restoreAction = TPAlertAction(type: .normal,
                                         title: resGetString("Restore")) { action in
            todo.restoreTrashTasks(tasks)
            completion?()
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        let format = resGetString("%ld tasks will be restored to their original list. Are you sure to restore?")
        let message = String(format: format, tasks.count)
        let alertController = TPAlertController(title: resGetString("Restore Task"),
                                                message: message,
                                                actions: [cancelAction, restoreAction])
        alertController.show()
    }
    
    func restoreTrashTask(_ task: TodoTask) {
        todo.restoreTrashTask(task)
    }

    
    // MARK: - 移动
    
    /// 移动任务
    func moveTask(_ task: TodoTask, completion: (()->Void)? = nil) {
        moveTasks([task], completion: completion)
    }
    
    func moveTasks(_ tasks: [TodoTask], completion: (()->Void)? = nil) {
        var lists = Set<TodoList?>()
        for task in tasks {
            lists.insert(task.list)
        }
    
        var currentList: TodoListRepresentable? = nil
        if lists.count == 1 {
            /// 属于同一列表
            let list = Array(lists)[0]
            if list == nil {
                /// 收件箱
                currentList = TodoSmartList.inbox
            } else {
                currentList = list
            }
        }

        let vc = TodoListMoveViewController(list: currentList)
        vc.didSelectList = { list in
            let toList = list as? TodoList
            todo.moveTodoTasks(tasks, toList: toList)
            completion?()
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    
    // MARK: -  移动任务到废纸篓
    
    func moveToTrash(with task: TodoTask, completion: (()->Void)? = nil) {
        todo.moveToTrash(with: [task])
        completion?()
    }
    
    func moveToTrash(with tasks: [TodoTask], completion: (()->Void)? = nil) {
        todo.moveToTrash(with: tasks)
        completion?()
    }
    
    // MARK: - 优先级
    func editPriority(for tasks: [TodoTask], sourceView: UIView, completion: (()->Void)? = nil) {
        let popoverView = TPMenuListPopoverView()
        let menuItem = TPMenuItem.item(with: TodoTaskPriority.priorities) { _, action in
            action.handleBeforeDismiss = true
        }
        
        popoverView.menuItems = [menuItem]
        popoverView.didSelectMenuAction = { action in
            if let priority = TodoTaskPriority(rawValue: action.tag) {
                todo.updateTasks(tasks, priority: priority)
            }
            
            completion?()
        }
        
        popoverView.show(from: sourceView,
                         sourceRect: sourceView.bounds,
                         isCovered: false,
                         preferredPosition: .topLeft,
                         permittedPositions: TPPopoverPosition.topPopoverPositions,
                         animated: true)
    }

    // MARK: - 检查
    func clickCheckbox(for task: TodoTask){
        let isCompleted = task.isCompleted
        if isCompleted {
            /// 取消完成
            todo.setCompleted(false, for: task)
            return
        }
        
        let checkType = task.checkType
        if checkType == .normal {
            /// 完成任务
            todo.setCompleted(true, for: task)
            return
        }
        
        /// 添加记录
        guard let progress = task.progress else {
            return
        }
    
        if progress.isCompleted {
            /// 此时目标进度已完成
            todo.setCompleted(true, for: task)
            return
        }

        if progress.recordType == .auto {
            /// 自动
            var recordValue = progress.autoRecordValue
            if checkType == .decrease {
                recordValue = -recordValue
            }
            
            todo.updateTask(task, incrementValue: recordValue)
            return
        }
        
        var inputType: TodoRecordInputType = .positive
        if progress.calculation == .update {
            inputType = .update
        } else if checkType == .decrease {
            inputType = .negative
        }
        
        let inputVC = TodoRecordInputViewController(inputType: inputType)
        inputVC.completion = { inputValue in
            todo.updateTask(task, inputValue: inputValue, inputType: inputType)
        }
        
        inputVC.popoverShow()
    }
    
    
    // MARK: - 编辑计划
    static func editSchedule(_ schedule: TaskSchedule?,
                             completion: ((TaskSchedule?)->Void)?) {
        let vc = TaskScheduleEditViewController(schedule: schedule)
        vc.didEndEditing = { schedule in
            completion?(schedule)
        }
        
        vc.popoverShowAsNavigationRoot()
    }
    
    static func editProgress(_ progress: TodoEditProgress?, completion: ((TodoEditProgress?)->Void)?) {
        let vc = TodoProgressEditViewController(progress: progress)
        vc.didEndEditing = { newProgress in
            completion?(newProgress)
        }
        
        vc.popoverShowAsNavigationRoot()
    }
    
    static func editTags(_ tags: Set<TodoTag>?, completion: ((Set<TodoTag>?)->Void)?) {
        let pickerVC = TodoTagPickerViewController(selectedTags: tags)
        pickerVC.didPickTags = { tags in
            completion?(tags)
        }
        
        pickerVC.popoverShowAsNavigationRoot()
    }
}
