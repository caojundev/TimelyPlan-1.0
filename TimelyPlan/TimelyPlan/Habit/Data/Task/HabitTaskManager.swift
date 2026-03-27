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
    
    /// 活动任务数组
    private(set) var activeTasks: [HabitTask] = []
    
    private var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    init() {
        self.activeTasks = getActiveTasks()
    }
    
    // MARK: - 任务操作
    func createTask(with editingTask: HabitEditingTask) {
        let content = CDHabitTask.newTask(with: editingTask)
        let task = HabitTask(content: content)
        let addTop = HabitSetting.shared.addHabitOnTop
        if addTop {
            self.activeTasks.insert(task, at: 0)
        } else {
            self.activeTasks.append(task)
        }
        
        CDHabitTask.syncOrders(for: self.activeTasks)
        
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
        
        content.update(with: editingTask)
        
        /// 替换活动任务数组中的旧任务
        if let index = self.activeTasks.indexOf(task) {
            let newTask = HabitTask(content: content)
            self.activeTasks.replaceElement(at: index, with: newTask)
        }
        
        self.updater.didUpdateHabitTask(task)
        HandyRecord.save()
    }
    
    /// 删除任务
    func deleteTask(_ task: HabitTask) {
        self.activeTasks.remove(task)

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

        /// 重新排序任务数组
        self.activeTasks = self.activeTasks.orderedElements()
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
        
        if isArchived {
            /// 归档任务
            self.activeTasks.remove(task)
        } else {
            /// 解除归档
            if !self.activeTasks.contains(task) {
                self.activeTasks.append(task)
                self.activeTasks.updateOrders()
            }
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
    
    func fetchActiveTasks(completion: @escaping([HabitTask]?) -> Void) {
        CDHabitTask.fetchActiveTasks { results in
            completion(results?.tasks)
        }
    }
}
