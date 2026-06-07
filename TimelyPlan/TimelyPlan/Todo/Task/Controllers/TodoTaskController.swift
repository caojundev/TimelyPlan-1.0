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
            editSchedule(for: tasks, completion: completion)
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
                             showClear: Bool? = nil,
                             completion: ((TaskSchedule?)->Void)?) {
        let vc = TodoScheduleEditViewController(schedule: schedule)
        if let showClear = showClear {
            vc.showClearButton = showClear
        }
        
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
    
    // MARK: - 编辑任务
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
    
    // MARK: - 编辑计划
    func editSchedule(for task: TodoTask) {
        editSchedule(for: [task], completion: nil)
    }
    
    func editSchedule(for tasks: [TodoTask], completion: (()->Void)? = nil) {
        var schedule: TaskSchedule?
        var showClear: Bool?
        if tasks.count == 1 {
            schedule = tasks[0].schedule
        } else {
            showClear = tasks.anySatisfy { $0.schedule != nil }
        }
        
        TodoTaskController.editSchedule(schedule, showClear: showClear) { newSchedule in
            todo.updateTasks(tasks, schedule: newSchedule)
            completion?()
        }
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
    func editPriority(for tasks: [TodoTask],
                      sourceView: UIView?,
                      preferredPosition: TPPopoverPosition = .topLeft,
                      completion: (()->Void)? = nil) {
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
        
        let permittedPositions = TPPopoverPosition.topPopoverPositions + TPPopoverPosition.bottomPopoverPositions
        popoverView.show(from: sourceView,
                         sourceRect: sourceView?.bounds,
                         isCovered: false,
                         preferredPosition: preferredPosition,
                         permittedPositions: permittedPositions,
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

    func clickCheckbox(for task: TodoTask, in listView: TodoTaskListView) {
        clickCheckbox(for: task) {isCompleted, execution in
            listView.setCompleted(isCompleted, for: task) { _ in
                execution?()
            }
        } progressHandler: { progress, execution in
            listView.setProgress(progress, for: task) {  _ in
                execution?()
            }
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
        var sections = Set<TodoSectionFeature>()
        for task in tasks {
            sections.insert(task.section)
        }
        
        var section: TodoSectionFeature? = nil
        if sections.count == 1 {
            /// 属于同一列
            section = Array(sections)[0]
        }
        
        let vc = TodoTaskMoveViewController(section: section)
        vc.didSelectSection = { section in
            todo.moveTasks(tasks, to: section)
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
    
    // MARK: - Providers
    func leadingSwipeActionsConfiguration(for task: TodoTask,
                                          in listView: TodoTaskListView,
                                          at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        /// 我的一天
        let myDayAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.setAddToMyDay(!task.isAddedToMyDay, for: task)
            completion(true)
        }
        
        var myDayImage: UIImage?
        if task.isAddedToMyDay {
            myDayImage = resGetImage("todo_task_action_removeFromMyDay_24@2x")
            myDayAction.backgroundColor = .gray(5)
        } else {
            myDayImage = resGetImage("todo_task_action_addToMyDay_24@2x")
            myDayAction.backgroundColor = .greenPrimary
        }
        
        myDayAction.image = myDayImage?.withTintColor(.white)
        actions.append(myDayAction)
        
        /// 优先级
        let priorityAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            let sourceView = listView.cellForRow(at: indexPath)
            self.editPriority(for: [task], sourceView: sourceView, preferredPosition: .bottomLeft)
            completion(true)
        }
        
        priorityAction.backgroundColor = .orange(4)
        priorityAction.image = resGetImage("todo_task_action_priority_24")?.withTintColor(.white)
        actions.append(priorityAction)
        
        /// 专注
        let focusAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.quickStartFocus(for: task)
            completion(true)
        }
        
        focusAction.backgroundColor = Color(0x5856D6)
        focusAction.image = resGetImage("focus_24")?.withTintColor(.white)
        actions.append(focusAction)
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    
    func trailingSwipeActionsConfiguration(for task: TodoTask,
                                           in listView: TodoTaskListView,
                                           at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        
        /// 移动
        let moveAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.moveTask(task)
            completion(true)
        }
        
        moveAction.backgroundColor = Color(0xFF9B00)
        moveAction.image = resGetImage("todo_task_action_move_24")?.withTintColor(.white)
        
        /// 计划
        let scheduleAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.editSchedule(for: task)
            completion(true)
        }

        scheduleAction.backgroundColor = .primary
        scheduleAction.image = resGetImage("todo_task_action_date_24")?.withTintColor(.white)
        
        /// 废纸篓
        let trashAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithMediumStyle()
            self.moveTaskToTrash(task)
            completion(true)
        }
                            
        trashAction.image = resGetImage("todo_task_action_trash_24")?.withTintColor(.white)
        actions = [scheduleAction, trashAction, moveAction]
        return UISwipeActionsConfiguration(actions: actions)
    }
}
