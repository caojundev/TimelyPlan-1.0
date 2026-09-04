//
//  GoalTaskProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/4.
//

import Foundation

/// 目标任务处理器代理
protocol GoalTaskProcessorDelegate: AnyObject {
    
    /// 创建目标任务
    func didCreateGoalTask(_ goalTask: GoalTask)
    
    /// 更新单个目标任务
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange)
    
    /// 批量更新目标任务
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo])
    
    /// 目标任务彻底删除
    func didDeleteGoalTasks(_ goalTasks: [GoalTask])
    
    /// 目标任务在列表中的顺序发生改变
    func didReorderGoalTask(in goalTasks: [GoalTask], fromIndex: Int, toIndex: Int)
}

extension GoalTaskProcessorDelegate {
    
    func didCreateGoalTask(_ goalTask: GoalTask) {}
    
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {}
    
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo]) {}
    
    func didDeleteGoalTasks(_ goalTasks: [GoalTask]) {}
    
    func didReorderGoalTask(in goalTasks: [GoalTask], fromIndex: Int, toIndex: Int) {}
}

class GoalTaskProcessorUpdater: NSObject,
                                GoalTaskProcessorDelegate {
    
    func didCreateGoalTask(_ goalTask: GoalTask) {
        notifyDelegates { (delegate: GoalTaskProcessorDelegate) in
            delegate.didCreateGoalTask(goalTask)
        }
    }
    
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        notifyDelegates { (delegate: GoalTaskProcessorDelegate) in
            delegate.didUpdateGoalTask(goalTask, with: change)
        }
    }
    
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo]) {
        notifyDelegates { (delegate: GoalTaskProcessorDelegate) in
            delegate.didUpdateGoalTasks(with: changeInfos)
        }
    }
    
    func didDeleteGoalTasks(_ goalTasks: [GoalTask]) {
        notifyDelegates { (delegate: GoalTaskProcessorDelegate) in
            delegate.didDeleteGoalTasks(goalTasks)
        }
    }
    
    func didReorderGoalTask(in goalTasks: [GoalTask], fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: GoalTaskProcessorDelegate) in
            delegate.didReorderGoalTask(in: goalTasks, fromIndex: fromIndex, toIndex: toIndex)
        }
    }
}
