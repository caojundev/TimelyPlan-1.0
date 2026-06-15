//
//  HabitTaskManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import CoreData

struct HabitTaskKey {
    static let identifier = "identifier"
    static let name = "name"
    static let order = "order"
    static let isArchived = "isArchived"
}

class HabitTaskManager {
    
    /// 任务处理更新器
    let updater = HabitTaskProcessorUpdater()

    private var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    // MARK: - 任务操作
    func createTask(with editingTask: HabitEditingTask) {
        let content = CDHabitTask.newTask(with: editingTask)
        let onTop = HabitSetting.shared.addHabitOnTop
        if onTop {
            content.order = CDHabitTask.minimumOrder - kOrderedStep
        } else {
            
            content.order = CDHabitTask.maximumOrder + kOrderedStep
        }
        
        let task = HabitTask(content: content)
        self.updater.didCreateHabitTask(task)
        HandyRecord.save()
    }
    
    func updateTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        if task.isSameEditingTask(as: editingTask) {
            return
        }
        
        guard let content = CDHabitTask.getTask(with: task.identifier) else {
            return
        }
        
        var isNameChanged: Bool = false
        if content.name != editingTask.name {
            isNameChanged = true
        }
        
        content.update(with: editingTask)
        updater.didUpdateHabitTask(task)
        HandyRecord.save()
        
        if isNameChanged {
            /// 更新对应专注会话的任务快照
            var feature = task.feature
            feature.snapshotName = editingTask.name
            FocusRepository.updateSession(with: feature)
        }
    }
    
    /// 删除任务
    func deleteTask(_ task: HabitTask) {
        if let cdTask = CDHabitTask.getTask(with: task.identifier) {
            self.context.delete(cdTask)
        }
        
        self.updater.didDeleteHabitTask(task)
        HandyRecord.save()
    }
    
    /// 重新排序
    func reorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        var reorderedTasks = tasks
        reorderedTasks.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        CDHabitTask.syncOrders(for: reorderedTasks)
        self.updater.didReorderTask(in: tasks, fromIndex: fromIndex, toIndex: toIndex)
        HandyRecord.save()
    }
    
    func setArchived(_ isArchived: Bool, for task: HabitTask) {
        guard task.isArchived != isArchived else {
            return
        }
        
        if let cdTask = CDHabitTask.getTask(with: task.identifier) {
            cdTask.isArchived = isArchived
        }
        
        self.updater.didChangeArchivedState(for: task)
        HandyRecord.save()
    }
    
    
    /// 获取所有习惯任务
    func getAllTasks() -> [HabitTask] {
        return CDHabitTask.getAllTasks().tasks
    }
    
    /// 获取归档任务
    func getArchivedTasks() -> [HabitTask] {
        return CDHabitTask.getArchivedTasks().tasks
    }
    
    /// 获取归档任务数目
    func getArchivedTasksCount() -> Int {
        return CDHabitTask.getArchivedTasksCount()
    }
    
    /// 获取活动任务
    func getActiveTasks() -> [HabitTask] {
        return CDHabitTask.getActiveTasks().tasks
    }
    
    func fetchArchivedTasks(completion: @escaping([HabitTask]?) -> Void) {
        CDHabitTask.fetchArchivedTasks { results in
            completion(results?.tasks)
        }
    }
    
    func fetchActiveTasks(completion: @escaping([HabitTask]?) -> Void) {
        CDHabitTask.fetchActiveTasks { results in
            completion(results?.tasks)
        }
    }
    
    func searchActiveTasks(containText text: String, completion:(@escaping([HabitTask]?) -> Void)) {
        CDHabitTask.searchActiveTasks(containText: text) { results in
            completion(results?.tasks)
        }
    }
}
