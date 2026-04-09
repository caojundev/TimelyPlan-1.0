//
//  TodoTaskManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/8.
//

import Foundation

class TodoTaskManager {
    
    /// 任务处理更新器
    let updater = TodoTaskProcessorUpdater()
    
    /// 创建任务
    func createTask(with quickAddTask: TodoQuickAddTask) {
        let content = CDTodoTask.createTodoTask(with: quickAddTask, onTop: true)
        let task = TodoTask(content: content)
        updater.didCreateTodoTask(task)
        HandyRecord.save()
    }
    
    /// 移动任务到新列表
    func moveTasks(_ tasks: [TodoTask], to list: TodoList?) {
        var tasksToMove = [TodoTask]()
        for task in tasks {
            if task.list?.identifier != list?.identifier {
                tasksToMove.append(task)
            }
        }
        
        guard tasksToMove.count > 0, CDTodoTask.moveTasks(tasksToMove, to: list) else {
            return
        }
        
        updater.didMoveTodoTasks(tasksToMove, to: list)
        HandyRecord.save()
    }
        
        
    /// 将任务移动到废纸篓
    func moveTasksToTrash(_ tasks: [TodoTask]) {
        guard CDTodoTask.moveTasksToTrash(tasks) else {
            return
        }
        
        updater.didMoveTodoTasksToTrash(tasks)
        HandyRecord.save()
    }
        
    /// 恢复废纸篓中的任务
    func restoreTrashTask(_ task: TodoTask) {
        restoreTrashTasks([task])
    }
    
    func restoreTrashTasks(_ tasks: [TodoTask]) {
        guard CDTodoTask.restoreTrashTasks(tasks) else {
            return
        }
        
        updater.didRestoreTrashTodoTasks(tasks)
        HandyRecord.save()
    }
    
    /// 清空废纸篓
    func emptyTrash() {
        CDTodoTask.emptyTrash { success in
            guard success else {
                return
            }
            
            self.updater.didEmptyTrash()
            HandyRecord.save()
        }
    }
    
    /// 彻底删除
    func deleteTasks(_ tasks: [TodoTask]) {
        guard CDTodoTask.deleteTasks(tasks) else {
            return
        }
        
        self.updater.didDeleteTodoTasks(tasks)
        HandyRecord.save()
    }
    
    // MARK: - 更新任务
    /// 更新优先级
    func updateTasks(_ tasks: [TodoTask], priority: TodoTaskPriority) {
        var tasksToUpdate = [TodoTask]()
        for task in tasks {
            if task.priority != priority {
                tasksToUpdate.append(task)
            }
        }

        guard tasksToUpdate.count > 0, CDTodoTask.updateTasks(tasksToUpdate, priority: priority) else {
            return
        }
        
        updater.didUpdateTodoTask(with: [])
        HandyRecord.save()
    }
    
    // MARK: - 完成任务
    func setCompleted(_ isCompleted: Bool, for tasks: [TodoTask]) {
        var tasksToUpdate = [TodoTask]()
        for task in tasks {
            if task.isCompleted != isCompleted {
                tasksToUpdate.append(task)
            }
        }
        
        guard tasksToUpdate.count > 0, CDTodoTask.setCompleted(isCompleted, for: tasksToUpdate) else {
            return
        }
        
        updater.didUpdateTodoTask(with: [])
        HandyRecord.save()
    }
}
