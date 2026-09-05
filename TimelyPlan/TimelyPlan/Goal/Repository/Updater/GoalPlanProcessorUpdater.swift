//
//  GoalPlanProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation

// MARK: - 目标计划处理器代理

protocol GoalPlanProcessorDelegate: AnyObject {
    
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?)
        
    /// 创建新目标计划
    func didCreateGoalPlan(_ goalPlan: GoalPlan)
    
    /// 更新目标计划
    func didUpdateGoalPlan(_ goalPlan: GoalPlan)
    
    /// 删除目标计划
    func didDeleteGoalPlan(_ goalPlan: GoalPlan)
    
    /// 归档目标计划
    func didArchiveGoalPlan(_ goalPlan: GoalPlan)
    
    /// 取消归档目标计划
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan)
    
    /// 通知目标计划的顺序发生改变
    func didReorderGoalPlan(in goalPlans: [GoalPlan],
                            fromIndex: Int,
                            toIndex: Int)
}

extension GoalPlanProcessorDelegate {
    
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?) {}
    
    func didCreateGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didUpdateGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didArchiveGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didReorderGoalPlan(in goalPlans: [GoalPlan],
                            fromIndex: Int,
                            toIndex: Int) {}
}

class GoalPlanProcessorUpdater: NSObject,
                                GoalPlanProcessorDelegate {
    
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didChangeRemoteGoalPlan(with: results)
        }
    }
    
    func didCreateGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didCreateGoalPlan(goalPlan)
        }
    }
    
    func didUpdateGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didUpdateGoalPlan(goalPlan)
        }
    }
    
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didDeleteGoalPlan(goalPlan)
        }
    }
    
    func didArchiveGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didArchiveGoalPlan(goalPlan)
        }
    }
    
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didUnarchiveGoalPlan(goalPlan)
        }
    }
    
    func didReorderGoalPlan(in goalPlans: [GoalPlan],
                            fromIndex: Int,
                            toIndex: Int) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didReorderGoalPlan(in: goalPlans,
                                        fromIndex: fromIndex,
                                        toIndex: toIndex)
        }
    }
}
