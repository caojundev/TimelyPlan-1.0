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
            moveTasksToTrash(tasks, completion: completion)
        case .restore:
            confirmRestoration(for: tasks, completion: completion)
        case .shred:
            confirmDeletion(for: tasks, completion: completion)
        case .addToMyDay:
            setAddToMyDay(true, for: tasks, completion: completion)
        case .removeFromMyDay:
            setAddToMyDay(false, for: tasks, completion: completion)
        }
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
    
    static func editTags(_ tags: Set<TodoTag>?, completion: ((Set<TodoTag>?)->Void)?) {
        let pickerVC = TodoTagPickerViewController(selectedTags: tags)
        pickerVC.didPickTags = { tags in
            completion?(tags)
        }
        
        pickerVC.popoverShowAsNavigationRoot()
    }
    
    // MARK: - 编辑
    func editSchedule(for task: TodoTask) {
        TodoTaskController.editSchedule(task.schedule) { schedule in
            todo.updateTask(task, schedule: schedule)
        }
    }
    
    func editTask(_ task: TodoTask) {
        guard let topVC = UIViewController.topPresented else {
            return
        }
        
        let editVC = TodoTaskEditViewController(task: task)
        let navController = UINavigationController(rootViewController: editVC)
        topVC.slidePresent(navController,
                           configure: .rightSlideConfigure,
                           isInteractive: true,
                           animated: true,
                           completion: nil)
    }
    
    // MARK: - 完成任务
    func setCompleted(_ isCompleted: Bool, for tasks: [TodoTask], completion: (()->Void)? = nil) {
        todo.updateTasks(tasks, isCompleted: isCompleted)
        completion?()
    }

    // MARK: - 我的一天
    func setAddToMyDay(_ isAddedToMyDay: Bool, for task: TodoTask) {
        setAddToMyDay(isAddedToMyDay, for: [task], completion: nil)
    }
    
    func setAddToMyDay(_ isAddedToMyDay: Bool, for tasks: [TodoTask], completion: (()->Void)? = nil) {
        todo.updateTasks(tasks, isAddedToMyDay: isAddedToMyDay)
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
    typealias TaskCompletedHandler = (_ isCompleted: Bool, _ execution: (() -> Void)?) -> Void
    typealias TaskProgressHandler = (_ progress: TodoEditProgress, _ execution: (() -> Void)?) -> Void
    private func executeCompletedHandler(_ handler: TaskCompletedHandler?,
                                         isCompleted: Bool,
                                         execution: @escaping () -> Void) {
           if let handler = handler {
               handler(isCompleted, execution)
           } else {
               execution()
           }
    }

    private func executeProgressHandler(_ handler: TaskProgressHandler?,
                                         progress: TodoEditProgress,
                                         execution: @escaping () -> Void) {
           if let handler = handler {
               handler(progress, execution)
           } else {
               execution()
           }
    }

    func clickCheckbox(for task: TodoTask,
                       completedHandler: TaskCompletedHandler?,
                       progressHandler: TaskProgressHandler?) {
        let isCompleted = task.isCompleted
        if isCompleted {
            let isCompleted = false
            executeCompletedHandler(completedHandler, isCompleted: isCompleted) {
                todo.updateTasks([task], isCompleted: isCompleted)
            }
            
            return
        }
        
        let checkType = task.checkType
        if checkType == .normal {
            /// 完成任务
            let isCompleted = true
            executeCompletedHandler(completedHandler, isCompleted: isCompleted) {
                todo.updateTasks([task], isCompleted: isCompleted)
            }
            
            return
        }
        
        /// 添加记录
        guard let progress = task.progress else {
            return
        }
    
        if let autoRecordedProgress = progress.autoRecordedProgress() {
            executeProgressHandler(progressHandler, progress: autoRecordedProgress) {
                todo.updateTask(task, progress: autoRecordedProgress)
            }
            
            return
        }
        
        let inputVC = TodoRecordInputViewController.inputViewController(for: progress)
        inputVC.completion = { value, type in
            let newProgress = progress.progressWithInputValue(value, inputType: type)
            self.executeProgressHandler(progressHandler, progress: newProgress) {
                todo.updateTask(task, progress: newProgress)
            }
        }
        
        inputVC.popoverShow()
    }
    
     static func editProgress(_ progress: TodoEditProgress?, completion: ((TodoEditProgress?)->Void)?) {
         let vc = TodoProgressEditViewController(progress: progress)
         vc.didEndEditing = { newProgress in
             completion?(newProgress)
         }
         
         vc.popoverShowAsNavigationRoot()
     }

    // MARK: - 快速开始专注
    func quickStartFocus(for task: TodoTask) {
        FocusPresenter.quickStartFocus(for: task)
    }
    
    // MARK: - 移动
    
    /// 移动任务
    func moveTask(_ task: TodoTask, completion: (()->Void)? = nil) {
        moveTasks([task], completion: completion)
    }
    
    func moveTasks(_ tasks: [TodoTask], completion: (()->Void)? = nil) {
        var lists = Set<TodoListFeature?>()
        for task in tasks {
            lists.insert(task.list)
        }
        
        var currentList: TodoListFeature? = nil
        if lists.count == 1 {
            /// 属于同一列表
            let list = Array(lists)[0]
            if list == nil {
                /// 收件箱
                currentList = TodoSmartList.inbox.feature
            } else {
                currentList = list
            }
        }

        let vc = TodoTaskListPickerViewController(list: currentList)
        vc.didSelectList = { list in
            todo.moveTasks(tasks, to: list)
            completion?()
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    
    // MARK: -  移动任务到废纸篓
    
    func moveTaskToTrash(_ task: TodoTask, completion: (()->Void)? = nil) {
        todo.moveTasksToTrash([task])
        completion?()
    }
    
    func moveTasksToTrash(_ tasks: [TodoTask], completion: (()->Void)? = nil) {
        todo.moveTasksToTrash(tasks)
        completion?()
    }
    
    // MARK: - 删除
    
    /// 弹窗确认删除列表
    func confirmDeletion(for task: TodoTask, completion: (()->Void)? = nil) {
        let deleteAction = TPAlertAction(type: .destructive, title: resGetString("Delete")) { action in
            todo.deleteTasks([task])
            completion?()
        }
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
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
        let deleteAction = TPAlertAction(type: .destructive, title: resGetString("Delete")) { action in
            todo.deleteTasks(tasks)
            completion?()
        }
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        let format = resGetString("%ld tasks will be permanently deleted.")
        let message = String(format: format, tasks.count)
        let alertController = TPAlertController(title: resGetString("Delete Task"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    
    // MARK: - 从废纸篓恢复
    func confirmRestoration(for task: TodoTask, completion: (()->Void)? = nil) {
        let restoreAction = TPAlertAction(type: .normal, title: resGetString("Restore")) { action in
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
    
    func restoreTrashTask(_ task: TodoTask) {
        todo.restoreTrashTask(task)
    }
}
