//
//  HabitTaskManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import CoreData

struct HabitTaskKey {
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
        self.activeTasks = self.getActiveTasks()
    }
    
    // MARK: - 任务操作
    func createTask(with editingTask: HabitEditingTask) {
        let content = CDHabitTask.newTask(with: editingTask)
        let task = HabitTask(content: content)
        self.activeTasks.append(task)
        self.activeTasks.updateOrders()
        self.updater.didCreateHabitTask(task)
        HandyRecord.save()
    }
    
    func updateTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        if task.isSameEditingTask(as: editingTask) {
            return
        }
        
        task.update(with: editingTask)
        self.updater.didUpdateHabitTask(task)
        HandyRecord.save()
    }
    
    /// 删除任务
    func deleteTask(_ task: HabitTask) {
        self.activeTasks.remove(task)
        self.context.delete(task.content)
        self.updater.didDeleteHabitTask(task)
        HandyRecord.save()
    }
    
    /// 重新排序
    func reorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        var reorderedTasks = tasks
        reorderedTasks.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        reorderedTasks.updateOrders()
        
        /// 重新排序任务数组
        self.activeTasks = self.activeTasks.orderedElements()
        self.updater.didReorderTask(in: tasks, fromIndex: fromIndex, toIndex: toIndex)
        HandyRecord.save()
    }
    
    func setArchived(_ isArchived: Bool, for task: HabitTask) {
        guard task.isArchived != isArchived else {
            return
        }
        
        task.isArchived = isArchived
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
    

    // MARK: - 获取任务
    /// 同步获取所有习惯任务
    func getAllTasks() -> [HabitTask] {
        return getTasks(with: nil)
    }
    
    /// 同步获取归档任务
    func getArchivedTasks() -> [HabitTask] {
        let predicate = archivedTaskPredicate()
        return getTasks(with: predicate)
    }
    
    /// 获取归档任务数目
    func getArchivedTasksCount() -> Int {
        let predicate = archivedTaskPredicate()
        let count = CDHabitTask.countOfEntries(with: predicate, in: .defaultContext)
        return count
    }
    
    /// 同步获取活动任务
    func getActiveTasks() -> [HabitTask] {
        let condition: PredicateCondition = (HabitTaskKey.isArchived, .notEqual(true))
        let predicate = NSPredicate.predicate(with: condition)
        return getTasks(with: predicate)
    }
    
    private func getTasks(with predicate: NSPredicate? = nil) -> [HabitTask] {
        let results: [CDHabitTask]? = CDHabitTask.findAll(with: predicate,
                                                          sortedBy: HabitTaskKey.order,
                                                          ascending: true,
                                                          in: .defaultContext)
        guard let results = results else {
            return []
        }
        
        var tasks = [HabitTask]()
        for result in results {
            let task = HabitTask(content: result)
            tasks.append(task)
        }
        
        return tasks
    }

    // MARK: - Helpers
    /// 已归档任务谓词
    private func archivedTaskPredicate() -> NSPredicate {
        let condition: PredicateCondition = (HabitTaskKey.isArchived, .isTrue)
        return NSPredicate.predicate(with: condition)
    }
    
}
