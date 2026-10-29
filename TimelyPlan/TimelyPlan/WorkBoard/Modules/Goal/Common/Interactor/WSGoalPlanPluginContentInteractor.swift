//
//  WSGoalPlanPluginContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation

// MARK: - 内容交互器基类

/// 目标计划组件的内容交互器基类。
///
/// 统一注册目标计划数据观察者，并把数据变更收敛到当前关注的目标计划；
/// 子类只需实现取数与交互。
class WSGoalPlanPluginContentInteractor: WSPluginContentInteractor,
                                         GoalPlanProcessorDelegate {
    
    /// 当前关注的目标计划标识。返回 nil 时对任意变更都刷新
    var goalPlanIdentifier: String? {
        return nil
    }
    
    /// 需要观察的数据类型
    var observedUpdaterOptions: GoalUpdaterOption {
        return .plan
    }
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 目标任务与记录变化会重新计算计划进度，观察计划即可覆盖
        /// 观察者由数据仓库弱引用持有，无需手动移除
        GoalRepository.addUpdater(self, for: observedUpdaterOptions)
    }
    
    /// 变更是否影响当前展示内容
    func isAffected(by goalPlan: GoalPlan) -> Bool {
        guard let identifier = goalPlanIdentifier else {
            return true
        }
        
        return goalPlan.identifier == identifier
    }
    
    // MARK: - GoalPlanProcessorDelegate
    /// 远程变更无法比对，保守地重新取数
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?) {
        pluginDataDidChange()
    }
    
    func didCreateGoalPlan(_ goalPlan: GoalPlan) {
        pluginDataDidChange()
    }
    
    func didUpdateGoalPlan(_ goalPlan: GoalPlan) {
        guard isAffected(by: goalPlan) else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {
        guard isAffected(by: goalPlan) else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didArchiveGoalPlan(_ goalPlan: GoalPlan) {
        guard isAffected(by: goalPlan) else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan) {
        guard isAffected(by: goalPlan) else {
            return
        }
        
        pluginDataDidChange()
    }
    
    /// 排序变化会影响列表类组件的展示顺序
    func didReorderGoalPlan(in goalPlans: [GoalPlan], fromIndex: Int, toIndex: Int) {
        pluginDataDidChange()
    }
}
