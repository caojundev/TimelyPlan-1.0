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
    
    /// 所有
    static let all: HabitUpdaterOption = [.task]
}

class Habit {

    /// 任务管理器
    private let taskManager = HabitTaskManager()
    
    // MARK: - 添加处理更新器
    func addUpdater(_ updater: AnyObject, for option: HabitUpdaterOption = .all) {
        if option.contains(.task) {
            taskManager.updater.addDelegate(updater)
        }
    }
    
    // MARK: - 任务处理
    func activeTasks() -> [HabitTask] {
        return self.taskManager.activeTasks
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
