//
//  TodoTaskManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/26.
//

import Foundation
import CoreData

class TodoTaskManager {
    
    /// 任务处理更新器
    let updater = TodoTaskProcessorUpdater()
    
    // MARK: - Provider
    /// 同步获取列表任务分组
    func getTaskGroups(for list: TodoListRepresentable,
                       with configuration: TodoListConfiguration,
                       shouldCollapse: ((TodoGroup) -> Bool)?) -> [TodoGroup] {
        let showCompleted = configuration.showCompleted
        let sort = list.validatedSort(configuration.sort)
        let tasks = tasks(in: list, sort: sort, showCompleted: showCompleted)
        switch configuration.groupType {
        case .none:
            return tasks.noneClassifiedTaskGroups()
        case .list:
            return tasks.listClassifiedTaskGroups(shouldCollapse: shouldCollapse)
        case .default:
            return tasks.statusClassifiedTaskGroups(shouldCollapse: shouldCollapse)
        case .startDate:
            return tasks.startDateClassifiedTaskGroups(shouldCollapse: shouldCollapse)
        case .dueDate:
            return tasks.dueDateClassifiedTaskGroups(shouldCollapse: shouldCollapse)
        case .priority:
            return tasks.priorityClassifiedTaskGroups(shouldCollapse: shouldCollapse)
        }
    }
    
    
    /// 获取列表中任务数目
    func numberOfTasks(in list: TodoListRepresentable) -> Int {
        let mode = list.listMode
        switch mode {
        case .user:
            return numberOfUserListTasks(for: list as! TodoList, showCompleted: false)
        case .inbox:
            return numberOfInboxTasks(showCompleted: false)
        case .completed:
            return numberOfCompletedTasks()
        case .trash:
            return numberOfTrashTasks()
        case .planned:
            return numberOfPlannedTasks()
        }
    }
    
    /// 获取列表中的任务
    private func tasks(in list: TodoListRepresentable,
                       sort: TodoSort,
                       showCompleted: Bool = true) -> [TodoTask] {
        let mode = list.listMode
        let sortTerms = list.sortTerms(for: sort)
        switch mode {
        case .user:
            let list = list as! TodoList
            return userListTasks(in: list, sortTerms: sortTerms, showCompleted: showCompleted)
        case .inbox:
            return inboxTasks(sortTerms: sortTerms, showCompleted: showCompleted)
        case .completed:
            return completedTasks(sortTerms: sortTerms)
        case .trash:
            return trashTasks(sortTerms: sortTerms)
        default:
            return plannedTasks(sortTerms: sortTerms)
        }
    }
    
    private func tasks(with predicate: NSPredicate, sortTerms: [SortTerm]) -> [TodoTask] {
        let tasks: [TodoTask]? = TodoTask.findAll(with: predicate,
                                                  sortTerms: sortTerms,
                                                  in: .defaultContext)
        return tasks ?? []
    }
    
    // MARK: - 用户列表
    private func userListTasksPredicate(for list: TodoList,
                                        showCompleted: Bool = true) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            (TodoTaskKey.list, .equal(list)),
            (TodoTaskKey.isRemoved, .isFalse)
        ]
        
        if !showCompleted {
            conditions.append((TodoTaskKey.isCompleted, .isFalse))
        }
        
        return conditions.andPredicate()
    }
    
    private func userListTasks(in list: TodoList,
                               sortTerms: [SortTerm],
                               showCompleted: Bool = true) -> [TodoTask] {
        let predicate = userListTasksPredicate(for: list, showCompleted: showCompleted)
        return tasks(with: predicate, sortTerms: sortTerms)
    }
    
    private func numberOfUserListTasks(for list: TodoList,
                                       showCompleted: Bool = true) -> Int {
        let predicate = userListTasksPredicate(for: list, showCompleted: showCompleted)
        let count = TodoTask.countOfEntries(with: predicate, in: .defaultContext)
        return count
    }
    
    // MARK: - 收件箱
    /// 收件箱任务谓词
    private func inboxTasksPredicate(showCompleted: Bool = true) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            (TodoTaskKey.list, .isEmpty),
            (TodoTaskKey.isRemoved, .isFalse)
        ]
        
        if !showCompleted {
            conditions.append((TodoTaskKey.isCompleted, .isFalse))
        }
        
        return conditions.andPredicate()
    }
    
    /// 按order排序的收件箱任务数组
    private func orderedInboxTasks() -> [TodoTask] {
        let sortTerm = (TodoTaskKey.order, true)
        return inboxTasks(sortTerms: [sortTerm])
    }
    
    /// 收件箱任务
    private func inboxTasks(sortTerms: [SortTerm], showCompleted: Bool = true) -> [TodoTask] {
        let predicate = inboxTasksPredicate(showCompleted: showCompleted)
        return tasks(with: predicate, sortTerms: sortTerms)
    }
    
    /// 收件箱待办任务数目
    private func numberOfInboxTasks(showCompleted: Bool = false) -> Int {
        let predicate = inboxTasksPredicate(showCompleted: showCompleted)
        let count = TodoTask.countOfEntries(with: predicate,
                                            in: .defaultContext)
        return count
    }
    
    // MARK: - 已完成
    /// 已完成任务谓词
    private func completedTasksPredicate() -> NSPredicate {
        let conditions: [PredicateCondition] = [
            (TodoTaskKey.isCompleted, .isTrue),
            (TodoTaskKey.isRemoved, .isFalse),
        ]
        
        return conditions.andPredicate()
    }
    
    /// 已完成任务
    private func completedTasks(sortTerms: [SortTerm]) -> [TodoTask] {
        let predicate = completedTasksPredicate()
        return tasks(with: predicate, sortTerms: sortTerms)
    }
    
    /// 已完成任务数目
    private func numberOfCompletedTasks() -> Int {
        let predicate = completedTasksPredicate()
        let count = TodoTask.countOfEntries(with: predicate, in: .defaultContext)
        return count
    }
    
    // MARK: - 计划内
    /// 已完成任务谓词
    private func plannedTasksPredicate() -> NSPredicate {
        /// 未删除并且未完成
        let andConditions: [PredicateCondition] = [
            (TodoTaskKey.isCompleted, .isFalse),
            (TodoTaskKey.isRemoved, .isFalse),
        ]
        
        /// 开始或结束日期不为空
        let orConditions: [PredicateCondition] = [
            (TodoTaskKey.startDate, .isNotEmpty),
            (TodoTaskKey.dueDate, .isNotEmpty),
        ]
        
        let predicate: NSPredicate = .andPredicate(andConditions: andConditions,
                                                   orConditions: orConditions)
        return predicate
    }
    
    /// 已完成任务
    private func plannedTasks(sortTerms: [SortTerm]) -> [TodoTask] {
        let predicate = plannedTasksPredicate()
        return tasks(with: predicate, sortTerms: sortTerms)
    }
    
    /// 已完成任务数目
    private func numberOfPlannedTasks() -> Int {
        let predicate = plannedTasksPredicate()
        let count = TodoTask.countOfEntries(with: predicate, in: .defaultContext)
        return count
    }
    
    // MARK: - 废纸篓
    /// 废纸篓任务谓词
    private func trashTasksPredicate() -> NSPredicate {
        /// 列表为空并且删除标记为true
        let conditions: [PredicateCondition] = [
            (TodoTaskKey.isRemoved, .isTrue)
        ]
        
        return conditions.andPredicate()
    }
    
    /// 废纸篓任务
    private func trashTasks(sortTerms: [SortTerm] = []) -> [TodoTask] {
        let predicate = trashTasksPredicate()
        return tasks(with: predicate, sortTerms: sortTerms)
    }
    
    /// 废纸篓任务数目
    private func numberOfTrashTasks() -> Int {
        let predicate = trashTasksPredicate()
        let count = TodoTask.countOfEntries(with: predicate, in: .defaultContext)
        return count
    }
    
    // MARK: - Processor
 
    /// 创建任务
    func createTodoTask(with quickAddTask: TodoQuickAddTask) {
        let task = TodoTask.createEntity(in: .defaultContext)
        task.identifier = UUID().uuidString
        task.name = quickAddTask.name
        if quickAddTask.isNoteEnabled {
            task.note = quickAddTask.note
        }
    
        task.isAddedToMyDay = quickAddTask.isAddedToMyDay
        task.priority = quickAddTask.priority
        task.schedule = quickAddTask.schedule
        task.creationDate = .now
        task.modificationDate = .now
        
        if let editProgress = quickAddTask.progress {
            task.progress = .newProgress(with: editProgress)
        }
        
        if let tags = quickAddTask.tags, tags.count > 0 {
            task.addToTags(tags as NSSet)
        }
    
        if let list = quickAddTask.list, !list.isDeleted {
            /// 添加到用户列表
            list.addTask(task, onTop: true)
        } else {
            #warning("添加到收件箱时更新order")
            /// 添加到收件箱
        }
        
        updater.didCreateTodoTask(task, in: task.list)
        todo.save()
    }
    
    func updateTask(_ task: TodoTask, tags: Set<TodoTag>?) {
        let oldTags = task.tags as? Set<TodoTag>
        if oldTags == tags {
            return
        }
        
        /// 删除标签
        var removeTags = oldTags
        if let tags = tags {
           removeTags = oldTags?.subtracting(tags)
        }
        
        if let removeTags = removeTags {
            task.removeFromTags(removeTags as NSSet)
        }
        
        /// 添加标签
        var addTags = tags
        if let oldTags = oldTags {
            addTags = tags?.subtracting(oldTags)
        }
        
        if let addTags = addTags {
            task.addToTags(addTags as NSSet)
        }
        
        task.modificationDate = .now
        let change = TodoTaskChange.tag(oldValue: oldTags, newValue: tags)
        let info = TodoTaskChangeInfo(task: task, change: change)
        updater.didUpdateTodoTask(with: [info])
        todo.save()
    }
    
    /// 更新计划
    func updateTask(_ task: TodoTask, schedule: TaskSchedule?) {
        let oldSchedule = task.schedule
        guard oldSchedule != schedule else {
            return
        }
        
        task.schedule = schedule
        task.modificationDate = .now
        let change = TodoTaskChange.schedule(oldValue: oldSchedule, newValue: schedule)
        let info = TodoTaskChangeInfo(task: task, change: change)
        updater.didUpdateTodoTask(with: [info])
        todo.save()
    }
    
    func updateTask(_ task: TodoTask, name: String?) {
        let oldName = task.name
        guard let name = name, name.count > 0, oldName != name else {
            return
        }
        
        task.name = name
        task.modificationDate = .now
        
        let change = TodoTaskChange.name(oldValue: oldName, newValue: name)
        let info = TodoTaskChangeInfo(task: task, change: change)
        updater.didUpdateTodoTask(with: [info])
        todo.save()
    }

    func updateTask(_ task: TodoTask, note: String?) {
        let oldNote = task.note
        guard oldNote != note else {
            return
        }
        
        task.note = note
        task.modificationDate = .now
        
        let change = TodoTaskChange.note(oldValue: oldNote, newValue: note)
        let info = TodoTaskChangeInfo(task: task, change: change)
        updater.didUpdateTodoTask(with: [info])
        todo.save()
    }
    
    func updateTasks(_ tasks: [TodoTask], isAddedToMyDay: Bool) {
        var infos = [TodoTaskChangeInfo]()
        for task in tasks {
            if task.isAddedToMyDay == isAddedToMyDay {
                continue
            }

            let change = TodoTaskChange.myDay(oldValue: task.isAddedToMyDay,
                                                   newValue: isAddedToMyDay)
            task.isAddedToMyDay = isAddedToMyDay
            task.modificationDate = .now
            
            let info = TodoTaskChangeInfo(task: task, change: change)
            infos.append(info)
        }
        
        guard infos.count > 0 else {
            return
        }
        
        updater.didUpdateTodoTask(with: infos)
        todo.save()
    }
    
    
    func updateTasks(_ tasks: [TodoTask], priority: TodoTaskPriority) {
        var infos = [TodoTaskChangeInfo]()
        for task in tasks {
            if task.priority == priority {
                continue
            }
        
            let change = TodoTaskChange.priority(oldValue: task.priority, newValue: priority)
            task.priority = priority
            task.modificationDate = .now
            
            let info = TodoTaskChangeInfo(task: task, change: change)
            infos.append(info)
        }
        
        guard infos.count > 0 else {
            return
        }
        
        updater.didUpdateTodoTask(with: infos)
        todo.save()
    }
    
    func updateTodoTask(_ task: TodoTask, schedule: TaskSchedule?) {
        guard task.schedule != schedule else {
            return
        }
        
        let change = TodoTaskChange.schedule(oldValue: task.schedule, newValue: schedule)
        task.schedule = schedule
        task.modificationDate = .now
        
        let info = TodoTaskChangeInfo(task: task, change: change)
        updater.didUpdateTodoTask(with: [info])
        todo.save()
    }
    
    
    // MARK: - 进度
    /// 移除进度
    private func removeProgress(forTask task: TodoTask) {
        guard let progress = task.progress else {
            return
        }
    
        let oldValue = progress.editProgress
        task.progress = nil
        task.modificationDate = .now
        
        NSManagedObjectContext.defaultContext.delete(progress)
        let change = TodoTaskChange.progress(oldValue: oldValue, newValue: nil)
        let info = TodoTaskChangeInfo(task: task, change: change)
        updater.didUpdateTodoTask(with: [info])
        todo.save()
    }
    
    func updateTask(_ task: TodoTask, editProgress: TodoEditProgress?) {
        guard let editProgress = editProgress else {
            /// 移除任务的进度
            removeProgress(forTask: task)
            return
        }
        
        let oldEditProgress = task.editProgress
        guard oldEditProgress != editProgress else {
            /// 将该任务设置为完成
            if !task.isCompleted, editProgress.isCompleted {
                setCompleted(true, for: task)
            }
            
            return
        }
        
        if let progress = task.progress {
            /// 更新已有进度
            progress.update(with: editProgress)
        } else {
            /// 创建新进度
            task.progress = .newProgress(with: editProgress)
        }
        
        task.modificationDate = .now
        if editProgress.isCompleted {
            /// 达到目标，完成任务
            setCompleted(true, for: task)
        }
        
        let change = TodoTaskChange.progress(oldValue: oldEditProgress, newValue: editProgress)
        let info = TodoTaskChangeInfo(task: task, change: change)
        updater.didUpdateTodoTask(with: [info])
        todo.save()
    }
    
    func updateTask(_ task: TodoTask, incrementValue: Int64) {
        guard let progress = task.progress else {
            return
        }
        
        let currentValue = progress.currentValue + incrementValue
        updateTask(task, currentValue: currentValue)
    }
    
    func updateTask(_ task: TodoTask, currentValue: Int64) {
        let checkType = task.checkType
        guard checkType != .normal, var editProgress = task.editProgress else {
            return
        }
        
        var newValue = currentValue
        if checkType == .decrease {
            if newValue <= editProgress.targetValue {
                newValue = editProgress.targetValue
            }
        } else {
            if newValue >= editProgress.targetValue {
                newValue = editProgress.targetValue
            }
        }
        
        editProgress.currentValue = newValue
        updateTask(task, editProgress: editProgress)
    }
    
    // MARK: - 完成任务
    func setCompleted(_ isCompleted: Bool, for task: TodoTask) {
        setCompleted(isCompleted, for: [task])
    }
    
    func setCompleted(_ isCompleted: Bool, for tasks: [TodoTask]) {
        var completeRecurringTasks = [TodoTask]()
        var infos = [TodoTaskChangeInfo]()
        for task in tasks {
            if isCompleted == task.isCompleted {
                continue
            }
        
            let change = TodoTaskChange.completed(oldValue: !isCompleted, newValue: isCompleted)
            task.isCompleted = isCompleted
            task.modificationDate = .now
            task.completionDate = isCompleted ? .now : nil
            
            let info = TodoTaskChangeInfo(task: task, change: change)
            infos.append(info)
            if task.isCompleted, task.isRecurringTask {
                completeRecurringTasks.append(task)
            }
        }
    
        guard infos.count > 0 else {
            return
        }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.didCompleteRecurringTasks(completeRecurringTasks)
        }
        
        updater.didUpdateTodoTask(with: infos)
        CATransaction.commit()
        todo.save()
    }
    
    /// 处理完成的重复任务
    private func didCompleteRecurringTasks(_ tasks: [TodoTask]) {
        let repeatScheduler = RepeatScheduler()
        var updatedRepeatTasks = [TodoTask]()
        var completedRepeatTasks = [TodoTask]()
        for task in tasks {
            guard let dateInfo = task.dateInfo,
                  let repeatRule = task.repeatRule,
                  let nextRepeatDate = repeatScheduler.nextRepeatDate(completionDate: dateInfo.startDate,
                                                                      matching: repeatRule,
                                                                      startDate: dateInfo.startDate) else {
                continue
            }
            
            /// 创建完成的重复任务
            guard let repeatTask = newRepeatTodoTask(for: task) else {
                continue
            }

            /// 将重复任务添加到当前任务列表
            task.list?.addToTasks(repeatTask)
            completedRepeatTasks.append(repeatTask)
            
            /// 取消当前任务完成状态
            task.isCompleted = false
            task.completionDate = nil
            
            /// 更新当前任务下一次开始日期
            var newDateInfo = dateInfo
            newDateInfo.setStartDate(nextRepeatDate)
            task.dateInfo = newDateInfo
            
            /// 重复规则
            if let newRepeatRule = repeatRule.copy() as? RepeatRule {
                let count = newRepeatRule.count ?? 0
                newRepeatRule.count = count + 1
                task.repeatRule = newRepeatRule
            }

            /// 取消完成所有步骤
            if let steps = task.steps as? Set<TodoStep> {
                for step in steps {
                    step.isCompleted = false
                }
            }
            
            task.modificationDate = .now
            updatedRepeatTasks.append(task)
        }
        
        guard updatedRepeatTasks.count > 0 else {
            return
        }
        
        updater.didCreateRepeatTodoTasks(completedRepeatTasks)
        updater.didUpdateActiveRepeatTodoTasks(updatedRepeatTasks)
        todo.save()
    }
    
    /// 创建重复完成任务
    private func newRepeatTodoTask(for task: TodoTask) -> TodoTask? {
        let repeatTask = TodoTask.createEntity(in: .defaultContext)
        /// 重新生成一个唯一标识
        repeatTask.identifier = UUID().uuidString
        repeatTask.order = task.order
        repeatTask.name = task.name
        repeatTask.priority = task.priority
        repeatTask.note = task.note
        repeatTask.creationDate = .now
        repeatTask.isCompleted = task.isCompleted
        repeatTask.completionDate = task.completionDate
        repeatTask.modificationDate = .now
        repeatTask.dateInfo = task.dateInfo
        repeatTask.reminder = task.reminder?.copy() as? TaskReminder
        
        /// 进度
        if let progress = task.progress {
            repeatTask.progress = .newProgress(with: progress)
        }
        
        /// 标签
        if let tags = task.tags, tags.count > 0 {
            repeatTask.addToTags(tags)
        }

        /// 步骤
        if let steps = task.steps as? Set<TodoStep> {
            var duplicatedSteps = Set<TodoStep>()
            for step in steps {
                let newStep = TodoStep.newStep(with: step)
                duplicatedSteps.insert(newStep)
            }
        
            if duplicatedSteps.count > 0 {
                repeatTask.addToSteps(duplicatedSteps as NSSet)
            }
        }
 
        return repeatTask
    }
    
    // MARK: - 移动
    
    func moveTodoTask(_ task: TodoTask, toList: TodoList?) {
        moveTodoTasks([task], toList: toList)
    }
    
    func moveTodoTasks(_ tasks: [TodoTask], toList: TodoList?) {
        var infos = [TodoTaskChangeInfo]()
        for task in tasks {
            let fromList = task.list
            if fromList == toList {
                continue
            }
            
            fromList?.removeFromTasks(task)
            toList?.addTask(task)
            
            let change = TodoTaskChange.list(oldValue: fromList, newValue: toList)
            let info = TodoTaskChangeInfo(task: task, change: change)
            infos.append(info)
        }
        
        updater.didMoveTodoTasks(with: infos)
        todo.save()
    }
    
    /// 将任务移动到废纸篓
    func moveToTrash(with tasks: [TodoTask]) {
        var movedTasks = [TodoTask]()
        for task in tasks {
            if task.isRemoved {
                continue
            }
            
            task.isRemoved = true
            movedTasks.append(task)
        }
        
        guard movedTasks.count > 0 else {
            return
        }
        
        updater.didMoveTodoTasksToTrash(movedTasks)
        todo.save()
    }
        
    /// 恢复废纸篓中的任务
    func restoreTrashTask(_ task: TodoTask) {
        restoreTrashTasks([task])
    }
    
    func restoreTrashTasks(_ tasks: [TodoTask]) {
        var restoredTasks = [TodoTask]()
        for task in tasks {
            guard task.isRemoved else {
                continue
            }
            
            task.isRemoved = false
            restoredTasks.append(task)
        }
        
        guard restoredTasks.count > 0 else {
            return
        }
        
        updater.didRestoreTrashTodoTasks(restoredTasks)
        todo.save()
    }
    
    /// 清空废纸篓
    func emptyTrash() {
        let tasks = trashTasks()
        guard tasks.count > 0 else {
            return
        }
        
        for task in tasks {
            task.list?.removeFromTasks(task)
        }
        
        NSManagedObjectContext.defaultContext.deleteObjects(tasks)
        updater.didDeleteTodoTasks(tasks)
        todo.save()
    }
    
    /// 彻底删除
    func deleteTask(_ task: TodoTask) {
        deleteTasks([task])
    }
    
    func deleteTasks(_ tasks: [TodoTask]) {
        NSManagedObjectContext.defaultContext.deleteObjects(tasks)
        updater.didDeleteTodoTasks(tasks)
        todo.save()
    }
    
    // MARK: - 任务排序
    func reorderTask(_ sourceTask: TodoTask,
                     postion: TodoTaskInsertPosition,
                     targetTask: TodoTask,
                     in list: TodoList?) -> Bool {
        var tasks: [TodoTask]
        if let list = list {
            /// 用户列表任务
            tasks = list.orderedTasks()
        } else {
            /// 收件箱列表任务
            tasks = orderedInboxTasks()
        }

        guard let _ = tasks.remove(sourceTask) else {
            return false
        }
        
        guard let targetIndex = tasks.indexOf(targetTask) else {
            return false
        }
        
        var insertIndex = targetIndex
        if postion == .after {
            insertIndex = targetIndex < tasks.count ? targetIndex + 1 : tasks.count
        }

        tasks.insert(sourceTask, at: insertIndex)
        tasks.updateOrders()
        todo.save()
        return true
    }
}

extension TodoTaskManager {
    
    // MARK: - update with change
    func updateTask(_ task: TodoTask, withChanges changes: [TodoTaskChange]) {
        var previousCompletionStatus = task.isCompleted
        var appliedChanges = Set<TodoTaskChange>()
        for change in changes {
            if updateTask(task, withChange: change) {
                appliedChanges.insert(change)
            }
        }
        
        if !task.isCompleted {
            let changesToProcess = appliedChanges
            for changeToProcess in changesToProcess {
                /// 进度
                guard case let .progress(_, newProgress) = changeToProcess, let newProgress = newProgress, newProgress.isCompleted else {
                    continue
                }
                
                let completionChange = TodoTaskChange.completed(oldValue: false, newValue: true)
                if updateTask(task, withCompletedChange: completionChange) {
                    appliedChanges.insert(completionChange)
                }
            }
        }
        
        guard appliedChanges.count > 0 else {
            return
        }
        
        let changeInfos = appliedChanges.map { TodoTaskChangeInfo(task: task, change: $0) }
        updater.didUpdateTodoTask(with: changeInfos)
        
        if !previousCompletionStatus, task.isCompleted, task.isRecurringTask {
            didCompleteRecurringTasks([task])
        }
        
        todo.save()
    }
    
    private func updateTask(_ task: TodoTask, withChange change: TodoTaskChange) -> Bool {
        switch change {
        case .list(_, _):
            return updateTask(task, withListChange: change)
        case .name(_, _):
            return updateTask(task, withNameChange: change)
        case .note(_, _):
            return updateTask(task, withNoteChange: change)
        case .priority(_, _):
            return updateTask(task, withPriorityChange: change)
        case .schedule(_, _):
            return updateTask(task, withScheduleChange: change)
        case .completed(_, _):
            return updateTask(task, withCompletedChange: change)
        case .myDay(_, _):
            return updateTask(task, withMyDayChange: change)
        case .tag(_, _):
            return updateTask(task, withTagChange: change)
        case .progress(_, _):
            return updateTask(task, withProgressChange: change)
        }
    }
    
    /// 更新列表
    private func updateTask(_ task: TodoTask, withListChange change: TodoTaskChange) -> Bool {
        guard case let .list(oldList, newList) = change, oldList != newList else {
            return false
        }
        
        oldList?.removeFromTasks(task)
        newList?.addTask(task)
        task.modificationDate = .now
        return true
    }
    
    /// 更新标签
    private func updateTask(_ task: TodoTask, withTagChange change: TodoTaskChange) -> Bool {
        guard case let .tag(oldTags, newTags) = change, oldTags != newTags else {
            return false
        }
        
        /// 删除标签
        var removeTags = oldTags
        if let newTags = newTags {
           removeTags = oldTags?.subtracting(newTags)
        }
        
        /// 添加标签
        var addTags = newTags
        if let oldTags = oldTags {
            addTags = newTags?.subtracting(oldTags)
        }

        task.updateTags(removeTags: removeTags, addTags: addTags)
        task.modificationDate = .now
        return true
    }
    
    /// 更新计划
    private func updateTask(_ task: TodoTask, withScheduleChange change: TodoTaskChange) -> Bool {
        guard case let .schedule(oldSchedule, newSchedule) = change, oldSchedule != newSchedule else {
            return false
        }
        
        task.schedule = newSchedule
        task.modificationDate = .now
        return true
    }

    /// 更新名称
    private func updateTask(_ task: TodoTask, withNameChange change: TodoTaskChange) -> Bool {
        guard case let .name(oldName, newName) = change, let newName = newName, newName.count > 0, oldName != newName else {
            return false
        }
        
        task.name = newName
        task.modificationDate = .now
        return true
    }
    
    /// 更新备注
    private func updateTask(_ task: TodoTask, withNoteChange change: TodoTaskChange) -> Bool {
        guard case let .note(oldNote, newNote) = change, oldNote != newNote else {
            return false
        }
        
        task.note = newNote
        task.modificationDate = .now
        return true
    }

    /// 更新我的一天
    private func updateTask(_ task: TodoTask, withMyDayChange change: TodoTaskChange) -> Bool {
        guard case let .myDay(oldValue, newValue) = change, oldValue != newValue else {
            return false
        }
        
        task.isAddedToMyDay = newValue
        task.modificationDate = .now
        return true
    }
    
    /// 更新优先级
    private func updateTask(_ task: TodoTask, withPriorityChange change: TodoTaskChange) -> Bool {
        guard case let .priority(oldValue, newValue) = change, oldValue != newValue else {
            return false
        }
        
        task.priority = newValue
        task.modificationDate = .now
        return true
    }
    
    /// 更新进度
    private func updateTask(_ task: TodoTask, withProgressChange change: TodoTaskChange) -> Bool {
        guard case let .progress(oldProgress, newProgress) = change, oldProgress != newProgress else {
            return false
        }
        
        guard let newProgress = newProgress else {
            /// 新进度为 nil，移除进度
            return task.removeProgress()
        }
        
        if let progress = task.progress {
            /// 更新已有进度
            progress.update(with: newProgress)
        } else {
            /// 创建新进度
            task.progress = .newProgress(with: newProgress)
        }
        
        task.modificationDate = .now
        return true
    }
    
    /// 更新完成状态
    private func updateTask(_ task: TodoTask, withCompletedChange change: TodoTaskChange) -> Bool {
        guard case let .completed(oldValue, newValue) = change, oldValue != newValue else {
            return false
        }
        
        task.isCompleted = newValue
        task.completionDate = newValue ? .now : nil
        task.modificationDate = .now
        return true
    }
}
