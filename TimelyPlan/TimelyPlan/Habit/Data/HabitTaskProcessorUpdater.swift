//
//  HabitTaskProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation

/// 习惯任务处理通知协议
protocol HabitTaskProcessorDelegate: AnyObject{
    
    /// 添加任务时通知
    func didCreateHabitTask(_ task: HabitTask)
    
    /// 更新任务通知
    func didUpdateHabitTask(_ task: HabitTask)
    
    /// 删除任务通知
    func didDeleteHabitTask(_ task: HabitTask)
    
    /// 改变了任务的归档状态
    func didChangeArchivedState(for task: HabitTask)
    
    /// 重新排序通知
    func didReorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int)
}

extension HabitTaskProcessorDelegate {
    func didCreateHabitTask(_ task: HabitTask) {}
    func didUpdateHabitTask(_ task: HabitTask) {}
    func didDeleteHabitTask(_ task: HabitTask) {}
    func didChangeArchivedState(for task: HabitTask) {}
    func didReorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {}
}

class HabitTaskProcessorUpdater: NSObject,
                                  HabitTaskProcessorDelegate {

    func didCreateHabitTask(_ task: HabitTask) {
        notifyDelegates { (delegate: HabitTaskProcessorDelegate) in
            delegate.didCreateHabitTask(task)
        }
    }
    
    func didUpdateHabitTask(_ task: HabitTask) {
        notifyDelegates { (delegate: HabitTaskProcessorDelegate) in
            delegate.didUpdateHabitTask(task)
        }
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        notifyDelegates { (delegate: HabitTaskProcessorDelegate) in
            delegate.didDeleteHabitTask(task)
        }
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        notifyDelegates { (delegate: HabitTaskProcessorDelegate) in
            delegate.didChangeArchivedState(for: task)
        }
    }
    
    func didReorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: HabitTaskProcessorDelegate) in
            delegate.didReorderTask(in: tasks, fromIndex: fromIndex, toIndex: toIndex)
        }
    }
}
