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
}
