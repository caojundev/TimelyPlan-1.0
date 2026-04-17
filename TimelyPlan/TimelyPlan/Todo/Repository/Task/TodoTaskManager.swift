//
//  TodoTaskManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/8.
//

import Foundation

/// 任务排序时插入位置
enum TodoTaskInsertPosition {
    case before
    case after
}

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
        
        if tasksToUpdate.count == 1 {
            let task = tasksToUpdate[0]
            let change: TodoTaskChange = .priority(oldValue: task.priority, newValue: priority)
            updater.didUpdateTodoTask(task, with: change)
        } else {
            var changeInfos: [TodoTaskChangeInfo] = []
            for task in tasksToUpdate {
                let change: TodoTaskChange = .priority(oldValue: task.priority, newValue: priority)
                let changeInfo = TodoTaskChangeInfo(task: task, change: change)
                changeInfos.append(changeInfo)
            }
            
            updater.didUpdateTodoTasks(with: changeInfos)
        }
        
        HandyRecord.save()
    }
    
    func updateTask(_ task: TodoTask, isCompleted: Bool) {
        updateTasks([task], isCompleted: isCompleted)
    }
    
    func updateTasks(_ tasks: [TodoTask], isCompleted: Bool) {
        var tasksToUpdate = [TodoTask]()
        for task in tasks {
            if task.isCompleted != isCompleted {
                tasksToUpdate.append(task)
            }
        }
        
        guard tasksToUpdate.count > 0, CDTodoTask.updateTasks(tasksToUpdate, isCompleted: isCompleted) else {
            return
        }
        
        if tasksToUpdate.count == 1 {
            let task = tasksToUpdate[0]
            let change: TodoTaskChange = .completed(oldValue: task.isCompleted, newValue: isCompleted)
            updater.didUpdateTodoTask(task, with: change)
        } else {
            var changeInfos: [TodoTaskChangeInfo] = []
            for task in tasksToUpdate {
                let change: TodoTaskChange = .completed(oldValue: task.isCompleted, newValue: isCompleted)
                let changeInfo = TodoTaskChangeInfo(task: task, change: change)
                changeInfos.append(changeInfo)
            }
            
            updater.didUpdateTodoTasks(with: changeInfos)
        }
        
        HandyRecord.save()
    }
    
    func updateTasks(_ tasks: [TodoTask], isAddedToMyDay: Bool) {
        var tasksToUpdate = [TodoTask]()
        for task in tasks {
            if task.isAddedToMyDay != isAddedToMyDay {
                tasksToUpdate.append(task)
            }
        }
        
        guard tasksToUpdate.count > 0, CDTodoTask.updateTasks(tasksToUpdate, isAddedToMyDay: isAddedToMyDay) else {
            return
        }
        
        if tasksToUpdate.count == 1 {
            let task = tasksToUpdate[0]
            let change: TodoTaskChange = .myDay(oldValue: task.isAddedToMyDay, newValue: isAddedToMyDay)
            updater.didUpdateTodoTask(task, with: change)
        } else {
            var changeInfos: [TodoTaskChangeInfo] = []
            for task in tasksToUpdate {
                let change: TodoTaskChange = .myDay(oldValue: task.isAddedToMyDay, newValue: isAddedToMyDay)
                let changeInfo = TodoTaskChangeInfo(task: task, change: change)
                changeInfos.append(changeInfo)
            }
            
            updater.didUpdateTodoTasks(with: changeInfos)
        }
        
        HandyRecord.save()
    }

    /// 更新任务进度
    func updateTask(_ task: TodoTask, progress: TodoEditProgress?) {
        guard task.progress != progress else {
            /// 进度相同，判断进度是否已完成
            if let progress = progress, progress.isCompleted{
                updateTask(task, isCompleted: true)
            }
            
            return
        }
        
        guard CDTodoTask.updateTask(task, progress: progress) else {
            return
        }
        
        var changes = [TodoTaskChange]()
        let change: TodoTaskChange = .progress(oldValue: task.progress, newValue: progress)
        changes.append(change)
        
        /// 检查完成状态是否改变
        if !task.isCompleted, let progress = progress, progress.isCompleted {
            let change: TodoTaskChange = .completed(oldValue: false, newValue: true)
            changes.append(change)
        }
        
        if changes.count == 1 {
            updater.didUpdateTodoTask(task, with: changes[0])
        } else {
            let infos = changes.map { TodoTaskChangeInfo(task: task, change: $0)}
            updater.didUpdateTodoTasks(with: infos)
        }
        
        HandyRecord.save()
    }
    
    func updateTask(_ task: TodoTask, name: String?) {
        guard task.name != name, CDTodoTask.updateTask(task, name: name) else {
            return
        }
        
        let change: TodoTaskChange = .name(oldValue: task.name, newValue: name)
        updater.didUpdateTodoTask(task, with: change)
        HandyRecord.save()
    }
    
    func updateTask(_ task: TodoTask, schedule: TaskSchedule?) {
        guard task.schedule != schedule, CDTodoTask.updateTask(task, schedule: schedule) else {
            return
        }
        
        let change: TodoTaskChange = .schedule(oldValue: task.schedule, newValue: schedule)
        updater.didUpdateTodoTask(task, with: change)
        HandyRecord.save()
    }
    
    func updateTask(_ task: TodoTask, tags: Set<TodoTag>?) {
        guard CDTodoTask.updateTask(task, tags: tags) else {
            return
        }
    
        let change: TodoTaskChange = .tag(oldValue: task.tagsSet, newValue: tags)
        updater.didUpdateTodoTask(task, with: change)
        HandyRecord.save()
    }
    
    func updateTask(_ task: TodoTask, note: String?) {
        guard task.note != note, CDTodoTask.updateTask(task, note: note) else {
            return
        }
        
        let change: TodoTaskChange = .note(oldValue: task.note, newValue: note)
        updater.didUpdateTodoTask(task, with: change)
        HandyRecord.save()
    }
    
    func updateTask(_ task: TodoTask, steps: [TodoStep]?) {
        guard CDTodoTask.updateTask(task, steps: steps) else {
            return
        }

        let change: TodoTaskChange = .step(oldValue: task.steps, newValue: steps)
        updater.didUpdateTodoTask(task, with: change)
        HandyRecord.save()
    }
    
    // MARK: - 排序
    func reorderTask(_ sourceTask: TodoTask,
                     postion: TodoTaskInsertPosition,
                     targetTask: TodoTask,
                     in list: TodoList?) {
        
        guard CDTodoTask.reorderTask(sourceTask, postion: postion, targetTask: targetTask, in: list) else {
            return
        }
        
        updater.didReorderTodoTask(sourceTask)
        HandyRecord.save()
    }
}

extension TodoTaskManager {
    
    /// 获取收件箱任务
    func fetchInboxTasks(showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchInboxTasks(showCompleted: showCompleted) { results in
            completion(results?.tasks)
        }
    }
    
    /// 获取已完成任务
    func fetchCompletedTasks(completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchCompletedTasks { results in
            completion(results?.tasks)
        }
    }
    
    /// 获取用户列表任务
    func fetchUserListTasks(in list: TodoList,
                            showCompleted: Bool = true,
                            completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchUserListTasks(in: list, showCompleted: showCompleted) { results in
            completion(results?.tasks)
        }
    }
    
    /// 获取废纸篓任务
    func fetchTrashTasks(completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchTrashTasks { results in
            completion(results?.tasks)
        }
    }
    
    func fetchTasks(for tag: TodoTag, completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchTasks(for: tag) { results in
            completion(results?.tasks)
        }
    }
}
