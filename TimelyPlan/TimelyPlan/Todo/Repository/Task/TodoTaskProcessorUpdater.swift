//
//  TodoTaskProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/29.
//

import Foundation

/// 待办任务处理通知协议
protocol TodoTaskProcessorDelegate: AnyObject {

    func didChangeRemoteTodoTask(with results: EntityChangeResults<TodoTask>?)
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?)
    
    /// 任务被添加到特定分组
    func didCreateTodoTask(_ task: TodoTask)

    /// 待办任务更新
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange)
    
    /// 批量任务更新
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo])
    
    /// 创建重复的待办任务
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask])

    /// 任务移动
    func didMoveTodoTasks(_ tasks: [TodoTask], to section: TodoSectionFeature)
    
    /// 恢复任务
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask])
    
    /// 移动任务到废纸篓
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask])
    
    /// 清空废纸篓
    func didEmptyTrash()
    
    /// 任务彻底删除
    func didDeleteTodoTasks(_ tasks: [TodoTask])
    
    /// 任务在列表中的顺序发生改变
    func didReorderTodoTask(_ task: TodoTask)
}

extension TodoTaskProcessorDelegate {
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {}
    
    func didCreateTodoTask(_ task: TodoTask) {}

    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {}
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {}
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {}

    func didMoveTodoTasks(_ tasks: [TodoTask], to section: TodoSectionFeature) {}
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {}
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {}
    
    func didEmptyTrash() {}
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {}
    
    func didReorderTodoTask(_ task: TodoTask) {}
}

class TodoTaskProcessorUpdater: NSObject, TodoTaskProcessorDelegate {
    
    func didChangeRemoteTodoTask(with results: EntityChangeResults<TodoTask>?) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didChangeRemoteTodoTask(with: results)
        }
    }
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didImportTodoTasks(tasks, to: list)
        }
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didCreateTodoTask(task)
        }
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didUpdateTodoTask(task, with: change)
        }
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didUpdateTodoTasks(with: changeInfos)
        }
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didCreateRepeatTodoTasks(repeatTasks, updatedTasks: updatedTasks)
        }
    }

    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didDeleteTodoTasks(tasks)
        }
    }
    
    func didMoveTodoTasks(_ tasks: [TodoTask], to section: TodoSectionFeature) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didMoveTodoTasks(tasks, to: section)
        }
    }
    
    func didReorderTodoTask(_ task: TodoTask) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didReorderTodoTask(task)
        }
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didRestoreTrashTodoTasks(tasks)
        }
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didMoveTodoTasksToTrash(tasks)
        }
    }
    
    func didEmptyTrash() {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didEmptyTrash()
        }
    }
}
