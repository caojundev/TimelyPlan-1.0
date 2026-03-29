//
//  Habit.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import CoreData

struct HabitUpdaterOption: OptionSet {
    
    let rawValue: Int
    
    /// 任务
    static let task = HabitUpdaterOption(rawValue: 1 << 1)
    
    /// 记录
    static let record = HabitUpdaterOption(rawValue: 2 << 1)
    
    /// 所有
    static let all: HabitUpdaterOption = [.task, .record]
}

class Habit {

    /// 任务管理器
    private let taskManager = HabitTaskManager()
    
    private let periodItemFetcher = HabitPeriodItemFetcher()
    
    let recordProcessor = HabitRecordProcessor()
    
    // MARK: - 添加处理更新器
    func addUpdater(_ updater: AnyObject, for option: HabitUpdaterOption = .all) {
        if option.contains(.task) {
            taskManager.updater.addDelegate(updater)
        }
        
        if option.contains(.record) {
            recordProcessor.updater.addDelegate(updater)
        }
    }
    
    // MARK: - Period Task
    
    func fetchScheduledPeriodItems(on date: Date = .now, completion: @escaping([HabitPeriodItem]?)->Void) {
        let activeTasks = taskManager.getActiveTasks()
        periodItemFetcher.fetchScheduledPeriodItems(for: activeTasks,
                                                       on: date,
                                                       completion: completion)
    }
    
    func fetchScheduledPeriodItems(in period: HabitDatePeriod,
                                   completion: @escaping([HabitPeriodItem])->Void) {
        let activeTasks = taskManager.getActiveTasks()
        periodItemFetcher.fetchScheduledPeriodItems(for: activeTasks,
                                                       in: period,
                                                       completion: completion)
    }
    
    
    func fetchPeriodItems(in period: HabitDatePeriod,
                          completion: @escaping([HabitPeriodItem])->Void) {
        let activeTasks = taskManager.getActiveTasks()
        periodItemFetcher.fetchPeriodItems(for: activeTasks,
                                            in: period,
                                            completion: completion)
    }
    
    /// 统计
    func fetchPeriodItem(for task: HabitTask,
                         in period: HabitDatePeriod,
                         completion: @escaping(HabitPeriodItem)->Void) {
        periodItemFetcher.fetchPeriodItem(for: task, in: period, completion: completion)
    }
    
    /// 报告模块获取任务
    func fetchReportPeriodItems(in period: HabitDatePeriod,
                                includeArchived: Bool,
                                completion: @escaping([HabitPeriodItem])->Void) {
        let tasks: [HabitTask]
        if includeArchived {
            tasks = taskManager.getAllTasks()
        } else {
            tasks = taskManager.getActiveTasks()
        }
        
        periodItemFetcher.fetchPeriodItems(for: tasks, in: period, completion: completion)
    }
    
    // MARK: - 任务获取
    func searchActiveTasks(containText text: String, completion:(@escaping([HabitTask]?) -> Void)) {
        self.taskManager.searchActiveTasks(containText: text, completion: completion)
    }
    
    func fetchActiveTasks(completion: @escaping([HabitTask]?) -> Void) {
        self.taskManager.fetchActiveTasks(completion: completion)
    }
    
    func fetchArchivedTasks(completion: @escaping([HabitTask]?) -> Void) {
        self.taskManager.fetchArchivedTasks(completion: completion)
    }
    
    func activeTasks() -> [HabitTask] {
        return self.taskManager.getActiveTasks()
    }
    
    /// 是否有归档任务
    var hasArchivedTask: Bool {
        return archivedTasksCount() != 0
    }
    
    func archivedTasks() -> [HabitTask] {
        return self.taskManager.getArchivedTasks()
    }
    
    /// 获取归档任务数目
    func archivedTasksCount() -> Int {
        return self.taskManager.getArchivedTasksCount()
    }
    
    func createTask(with editingTask: HabitEditingTask) {
        self.taskManager.createTask(with: editingTask)
    }
    
    func updateTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        self.taskManager.updateTask(task, with: editingTask)
    }
    
    /// 删除任务
    func deleteTask(_ task: HabitTask) {
        self.taskManager.deleteTask(task)
    }
    
    /// 重新排序
    func reorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        self.taskManager.reorderTask(in: tasks, fromIndex: fromIndex, toIndex: toIndex)
    }

    /// 归档
    func setArchived(_ isArchived: Bool, for task: HabitTask) {
        self.taskManager.setArchived(isArchived, for: task)
    }
}
