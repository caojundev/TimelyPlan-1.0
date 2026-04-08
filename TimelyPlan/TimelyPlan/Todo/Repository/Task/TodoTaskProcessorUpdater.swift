//
//  TodoTaskProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/29.
//

import Foundation

/// 待办任务处理通知协议
protocol TodoTaskProcessorDelegate: AnyObject {

    /// 更新进行中的重复任务
    func didUpdateActiveRepeatTodoTasks(_ tasks: [TodoTask])
    
    /// 创建重复的待办任务
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask])

    /// 任务被添加到特定分组
    func didCreateTodoTask(_ task: TodoTask)

    /// 待办任务更新
    func didUpdateTodoTask(with infos: [TodoTaskChangeInfo])
    
    /// 任务移动
    func didMoveTodoTasks(_ tasks: [TodoTask], to list: TodoList?)
    
    /// 恢复任务
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask])
    
    /// 移动任务到废纸篓
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask])
    
    /// 清空废纸篓
    func didEmptyTrash()
    
    /// 任务彻底删除
    func didDeleteTodoTasks(_ tasks: [TodoTask])
    
    /// 任务在列表中的顺序发生改变
    func didReorderTodoTask(_ task: TodoTask, fromIndex: Int, toIndex: Int)
}

extension TodoTaskProcessorDelegate {
    
    func didEmptyTrash() { }
}

class TodoTaskProcessorUpdater: NSObject, TodoTaskProcessorDelegate {
    
    /// 更新进行中的重复任务
    func didUpdateActiveRepeatTodoTasks(_ tasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didUpdateActiveRepeatTodoTasks(tasks)
        }
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didCreateRepeatTodoTasks(repeatTasks)
        }
    }
    
    func didUpdateTodoTask(with infos: [TodoTaskChangeInfo]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didUpdateTodoTask(with: infos)
        }
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didCreateTodoTask(task)
        }
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didDeleteTodoTasks(tasks)
        }
    }
    
    func didMoveTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didMoveTodoTasks(tasks, to: list)
        }
    }
    
    func didReorderTodoTask(_ task: TodoTask, fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didReorderTodoTask(task, fromIndex: fromIndex, toIndex: toIndex)
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
