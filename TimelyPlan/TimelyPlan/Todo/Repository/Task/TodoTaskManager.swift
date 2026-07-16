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
        let onTop = TodoSetting.shared.addTaskOnTop
        let content = CDTodoTask.createTodoTask(with: quickAddTask, onTop: onTop)
        let task = TodoTask(content: content)
        updater.didCreateTodoTask(task)
        HandyRecord.save()
    }
    
    /// 移动任务到新列表
    func moveTasks(_ tasks: [TodoTask], to section: TodoSectionFeature) {
        var tasksToMove = [TodoTask]()
        for task in tasks {
            if task.section != section {
                tasksToMove.append(task)
            }
        }
        
        guard tasksToMove.count > 0, CDTodoTask.moveTasks(tasksToMove, to: section) else {
            return
        }

        if tasksToMove.count == 1 {
            let task = tasksToMove[0]
            let change: TodoTaskChange = .section(oldValue: task.section, newValue: section)
            updater.didUpdateTodoTask(task, with: change)
        } else {
            var changeInfos: [TodoTaskChangeInfo] = []
            for task in tasksToMove {
                let change: TodoTaskChange = .section(oldValue: task.section, newValue: section)
                let changeInfo = TodoTaskChangeInfo(task: task, change: change)
                changeInfos.append(changeInfo)
            }
            
            updater.didUpdateTodoTasks(with: changeInfos)
        }
        
        updater.didMoveTodoTasks(tasksToMove, to: section)
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
        
    /// 将特定列表中所有任务移到废纸篓
    func moveAllTasksToTrash(in list: TodoList) {
        guard let cdTasks = CDTodoList.moveAllTasksToTrash(in: list) else {
            return
        }
        
        let tasks = Array(cdTasks).toTasks
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
    
    // MARK: - 导入任务
    func importTasks(_ tasks: [TodoImportTask], to list: TodoList?) {
        let contents = CDTodoTask.importTasks(tasks, to: list)
        guard contents.count > 0 else {
            return
        }
        
        let importedTasks = contents.toTasks
        updater.didImportTodoTasks(importedTasks, to: list)
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
        
        let change: TodoTaskChange = .progress(oldValue: task.progress, newValue: progress)
        updater.didUpdateTodoTask(task, with: change)
        
        if !task.isCompleted, let progress = progress, progress.isCompleted {
            updateTask(task, isCompleted: true)
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
        
        /// 更新对应专注会话的任务快照
        var feature = task.feature
        feature.snapshotName = name
        FocusRepository.updateSession(with: feature)
    }
    
    // MARK: - 更新计划
    func updateTasks(_ tasks: [TodoTask], schedule: TaskSchedule?) {
        var tasksToUpdate = [TodoTask]()
        for task in tasks {
            if task.schedule != schedule {
                tasksToUpdate.append(task)
            }
        }
        
        guard tasksToUpdate.count > 0,
              CDTodoTask.updateTasks(tasksToUpdate, schedule: schedule) else {
            return
        }
        
        if tasksToUpdate.count == 1 {
            let task = tasksToUpdate[0]
            let change: TodoTaskChange = .schedule(oldValue: task.schedule, newValue: schedule)
            updater.didUpdateTodoTask(task, with: change)
        } else {
            var changeInfos: [TodoTaskChangeInfo] = []
            for task in tasksToUpdate {
                let change: TodoTaskChange = .schedule(oldValue: task.schedule, newValue: schedule)
                let changeInfo = TodoTaskChangeInfo(task: task, change: change)
                changeInfos.append(changeInfo)
            }
            
            updater.didUpdateTodoTasks(with: changeInfos)
        }
        
        HandyRecord.save()
    }
    
    func updateTask(_ task: TodoTask, schedule: TaskSchedule?) {
        updateTasks([task], schedule: schedule)
    }
    
    // MARK: - 标签
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
    
    // MARK: - Update with change
    func updateTask(_ task: TodoTask, changes: [TodoTaskChange]) {
        guard let appliedChanges = CDTodoTask.updateTask(task, changes: changes) else {
            return
        }
        
        let changeInfos = appliedChanges.map { TodoTaskChangeInfo(task: task, change: $0) }
        updater.didUpdateTodoTasks(with: changeInfos)
        HandyRecord.save()
    }
    
    // MARK: - 完成状态
    
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
        
        /// 更新
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

        /// 处理重复任务
        var recurringTasks: [TodoTask]?
        if isCompleted {
            recurringTasks = tasksToUpdate.filter { $0.isRecurringTask }
        }
        
        if let recurringTasks = recurringTasks, recurringTasks.count > 0 {
            didCompleteRecurringTasks(recurringTasks)
        }
        
        HandyRecord.save()
    }
    
    /// 处理完成的重复任务
    private func didCompleteRecurringTasks(_ tasks: [TodoTask]) {
        var updatedTasks = [TodoTask]()
        var createdRepeatTasks = [TodoTask]()
        for task in tasks {
            guard let nextSchedule = task.nextSchedule else {
                continue
            }
            
            /// 创建当前周期已完成任务
            let content = CDTodoTask.createTodoTask(with: task.currentOccurrenceQuickAddTask)
            let createdTask = TodoTask(content: content)
            createdRepeatTasks.append(createdTask)
        
            /// 更新任务为下一重复周期数据
            task.reset(with: nextSchedule)
            if CDTodoTask.updateTodoTask(task) {
                updatedTasks.append(task)
            }
        }
        
        updater.didCreateRepeatTodoTasks(createdRepeatTasks, updatedTasks: updatedTasks)
    }
}

extension TodoTaskManager {

    func getTask(with identifier: String) -> TodoTask? {
        if let cdTask = CDTodoTask.getItem(with: identifier) {
            return TodoTask(content: cdTask)
        }
        
        return nil
    }
    
    /// 获取用户列表任务
    func fetchSmartListTasks(in list: TodoSmartList,
                             showCompleted: Bool = true,
                             completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchSmartListTasks(in: list, showCompleted: showCompleted) { results in
            completion(results?.toTasks)
        }
    }
    
    /// 获取用户列表任务
    func fetchUserListTasks(in list: TodoList,
                            showCompleted: Bool = true,
                            completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchUserListTasks(in: list, showCompleted: showCompleted) { results in
            completion(results?.toTasks)
        }
    }

    func fetchAllTasks(showCompleted: Bool = false,
                       completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchAllTasks(showCompleted: showCompleted) { results in
            completion(results?.toTasks)
        }
    }
    
    
    func fetchTasks(tag: TodoTag, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchTasks(tag: tag, showCompleted: showCompleted) { results in
            completion(results?.toTasks)
        }
    }
    
    func fetchTasks(filter: TodoFilter, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        guard let filterRule = filter.rule else {
            completion(nil)
            return
        }
        
        fetchTasks(filterRule: filterRule, showCompleted: showCompleted, completion: completion)
    }
    
    func fetchTasks(filterRule: TodoFilterRule, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchTasks(filterRule: filterRule,
                              showCompleted: showCompleted) { results in
            completion(results?.toTasks)
        }
    }
    
    func fetchUncompletedTaskCount(for item: IdentifiableItem, completion: @escaping(Int) -> Void) {
        CDTodoTask.fetchUncompletedTaskCount(for: item, completion: completion)
    }
    
    /// 获取已完成任务
    func fetchCompletedTasks(in range: DateRange, completion: @escaping([TodoTask]?) -> Void) {
        guard let start = range.startDate, let end = range.endDate else {
            completion(nil)
            return
        }
        
        let dateInterval = DateInterval(start: start, end: end)
        CDTodoTask.fetchCompletedTasks(in: dateInterval) { results in
            completion(results?.toTasks)
        }
    }
    
    /// 搜索任务
    func searchTasks(matching searchText: String,
                     options: TodoSearchOptions,
                     completion: @escaping ([TodoTask]?) -> Void) {
        CDTodoTask.searchTasks(matching: searchText,
                               options: options) { results in
            completion(results?.toTasks)
        }
    }
    
    /// 获取日历事项任务
    func fetchCalendarEventTasks(in range: DateInterval, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchCalendarEventTasks(in: range, showCompleted: showCompleted) { results in
            let tasks = results?.toTasks
            TodoTaskManager.calculateEventTasks(for: tasks,
                                                in: range,
                                                showCompleted: showCompleted,
                                                completion: completion)
        }
    }
    
    func fetchMyDayEventTasks(in range: DateInterval, showCompleted: Bool = true, completion: @escaping([TodoTask]?) -> Void) {
        CDTodoTask.fetchMyDayEventTasks(in: range, showCompleted: showCompleted) { results in
            let tasks = results?.toTasks
            TodoTaskManager.calculateEventTasks(for: tasks,
                                                in: range,
                                                showCompleted: showCompleted,
                                                completion: completion)
        }
    }
    
    func fetchNotifiableTasks(completion: @escaping ([TodoTask]?) -> Void) {
        CDTodoTask.fetchNotifiableTasks { results in
            completion(results?.toTasks)
        }
    }
    
    private static func calculateEventTasks(for tasks: [TodoTask]?,
                                            in range: DateInterval,
                                            showCompleted: Bool = true,
                                            completion: @escaping(([TodoTask]?) -> Void)) {
        guard let tasks = tasks else {
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let eventTasks = tasks.eventTasks(in: range, showCompleted: showCompleted)
            DispatchQueue.main.async {
                completion(eventTasks)
            }
        }
    }
    
}
